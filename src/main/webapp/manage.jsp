<%@page import="java.util.LinkedHashSet"%>
<%@page import="java.util.HashSet"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.util.Iterator"%>
<%@page import="redis.clients.jedis.Jedis"%>
<%@page import="java.util.Set"%>
<%@page import="student_info_manage_system.StudentInfo"%>
<%@page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
response.addHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.addHeader("Cache-Control", "pre-check=0, post-check=0");
response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache">  
<meta http-equiv="cache-control" content="no-cache">  
<meta http-equiv="expires" content="0">
<link rel="stylesheet" href="./reset.css" type="text/css" />
<style>
td {
	width: 160px;
	height: 30px;
	border-top: 1px solid black;
	border-left: 1px solid black;
	text-align: center;
	line-height: 30px;
}

table {
	border-bottom: 1px solid black;
	border-right: 1px solid black;
}
</style>
<script type="text/javascript" src="http://code.jquery.com/jquery-latest.js"></script>
<script type="text/javascript">
	function newInfo() {
		if (!$("#newInfo").length > 0) {
			var $div = $("<div id=\"newInfo\"></div>")
			$(document.body).append($div);
			var $form = $("<form action=\"http://localhost:8585/student_info_manage_system/insertinfo\" method=\"Post\" id=\"submitInfo\"><form/>");
			$("#newInfo").append($form);
			$("form").append("<p>student id\:</p>");
			$("form").append("<input type=\"text\" name=\"id\"/>");
			$("form").append("<p>student name\:</p>");
			$("form").append("<input type=\"text\" name=\"name\"/>");
			$("form").append("<p>student birthday\:</p>");
			$("form").append("<input type=\"text\" name=\"birthday\"/>");
			$("form").append("<p>student description\:</p>");
			$("form").append("<input type=\"text\" name=\"description\"/>");
			$("form").append("<p>student average score\:</p>");
			$("form").append("<input type=\"text\" name=\"avgScore\" value=\"0\"/>");
			$("form").append("<br/>");
			$("form").append("<input type=\"button\" onclick=\"isSubmit()\" value=\"提交\"/>");
			$("#newInfo").append("<input type=\"button\" value=\"取消\" onclick=\"cancelInsert()\"/>");
			$("input[name$='id']").focusout(function(e) {
				if ($(this).val() == "") {
					alert("请输入学生ID！");
					$(this).val("");
				}
				else if($(this).val().length>40){
					alert("您输入的信息过长！");
				}
			});

			$("input[name$='name']").focusout(function(e) {
				if ($(this).val() == "") {
					alert("请输入学生姓名！");
					$(this).val("");
				}
				else if($(this).val().length>40){
					alert("您输入的信息过长！");
				}
			});

			$("input[name$='avgScore']").focusout(function(e) {
				var $reg = /^\d+(\.{0,1}\d+){0,1}$/;
				if ($(this).val() != "0" && !$(this).val().match($reg)) {
					alert("请输入非负数！");
					$(this).val("");
				}
			});
			
			$("input[name$='description']").focusout(function(e){
				if($(this).val().length>255){
					alert("您输入的信息太长！");
				}
			});
			
			$("input[name$='birthday']").focusout(function(e) {
				var reg = /^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$/;
				if ($(this).val() != "") {
					if (!$(this).val().match(reg)) {
						alert("生日格式错误！格式应为YYYY-MM-DD");
						$(this).val("");
					}
				}
			});
		}
	}

	function isSubmit() {
		if ($("input[name$='name']").val() == "" || $("input[name$='id']").val() == ""){
			alert("请补全学生ID和学生姓名信息");
		}
		else if($("input[name$='name']").val().length>40 || $("input[name$='id']").val().length >40 || $("input[name$='description']").val().length>255){
			
		}
		else {
			alert($("input[name$='description']").val());
			$("#submitInfo").submit();
		}
	}

	function cancelInsert() {
		$("#newInfo").remove();
	}
	function cancelUpdate(){
		$("#updateInfo").remove();
	}
</script>
<title>学生数据管理系统</title>
</head>
<body>
	<%!
	int contentPage;
	long maxPage;
	StudentInfo[] students = new StudentInfo[10];
	Jedis jedis = new Jedis("119.23.32.233", 6379);
	Set<String> idList = new LinkedHashSet<String>();

	StudentInfo[] setStudentInfo(Set<String> idList, Jedis jedis) {
		StudentInfo[] studentInfos = new StudentInfo[10];
		Iterator<String> idIterator = idList.iterator();
		for (int i = 0; i < 10; i++) {
			if (idIterator.hasNext()) {
				String studentId = idIterator.next();
				String studentInfo = jedis.hget("student_info", studentId);
				JSONObject jsonObject = JSONObject.fromObject(studentInfo);
				studentInfos[i] = (StudentInfo) JSONObject.toBean(jsonObject, StudentInfo.class);
			}
		}
		return studentInfos;
	}
	void getIdList(int contentPage, Jedis jedis, Set<String> idList) {
		idList.clear();
		idList.addAll(jedis.zrevrange("sorted_id", (contentPage - 1) * 10, contentPage * 10-1));
	}
	%>
	<%
	if(request.getParameter("contentPage")==null){
		contentPage=1;
	}
	else{
		contentPage=Integer.parseInt(request.getParameter("contentPage"));
	}
	maxPage = ((jedis.zcount("sorted_id", 0, 1000) - 1)/ 10) + 1;
	getIdList(contentPage, jedis, idList);
	students = setStudentInfo(idList, jedis);
	%>
	<div>
		<input type="button" value="新建一条数据" onclick="newInfo()" />
		<table>
			<tr>
				<td>student_id</td>
				<td>student_name</td>
				<td>student_birthday</td>
				<td>description</td>
				<td>avarage_score</td>
				<td>options</td>
			</tr>
			<%
			Iterator<String> idIterator = idList.iterator();
			int count = 0;
			for (int i = 0; i < 10; i++) {
				if (idIterator.hasNext()) {
			%>
			<tr id="<%=count + 1%>">
				<td id=><%=idIterator.next()%></td>
				<td><%=students[count].getName()%></td>
				<td><%=students[count].getBirthday()%></td>
				<td><%=students[count].getDescription()%></td>
				<td><%=students[count].getAvgScore()%></td>
				<td><a href="#" style="margin-right: 20px" value="update">修改</a><a href="#" value="delete">删除</a></td>
			</tr>
			<%
					count++;
				} 
				else
					break;
			}
			%>
		</table>
	</div>
	<div>
		<a href="" value="pages" style="margin:10px">1</a>
		<%
		if(contentPage>=5){
		%>
		<p style="display:inline;margin:10px">…</p>
		<%
		}
		for(int i = contentPage-2 ; i <= contentPage+2 ; i++){
			if(i<=1)
				continue;
			if(i==maxPage){
				break;
			}
		%>
			<a href="" value="pages" style="margin:10px"><%=i %></a>
		
		<%
		}
	    if((contentPage+2)<(maxPage-1)){
		%>
		    	<p style="display:inline;margin:10px">…</p>
		<%
		}
		%>
			<a href="" value="pages" style="margin:10px"><%=maxPage %></a>
	</div>
	<script type="text/javascript">
		<!-- changePage事件 -->
		$("a[value$='pages']").click(function(){
			var $contentPage = $(this).html();
			var timeStamp=new Date().getTime();
			var url = "http://119.23.32.233:8888/student_info_manage_system/manage.jsp?contentPage="+$contentPage+"&timestamp="+timeStamp;
			$(this).attr("href",url);
		});
		
		<!-- delete事件 -->
		$("a[value$='delete']").click(function(){
			var $raw = $(this).parent().parent().attr('id');
			var $id = $("#"+$raw+">td").eq(0).html();
			if(confirm("确认删除这条数据吗？")){
				var $form = $("<form action=\"http://119.23.32.233:8888/student_info_manage_system/deleteinfo\" method=\"Post\" id=\"submitInfo\"><form/>");
				$("#submitInfo").css("display",'none');
				$("body").append($form);
				var $idTextarea = $("<input type=\"text\" name=\"id\" value=\""+$id+"\"/>");
				$("#submitInfo").append($idTextarea);
				$("#submitInfo").submit();
			}
		});
		
		<!-- update事件 -->
		$("a[value$='update']").click(function(){
			var $raw = $(this).parent().parent().attr('id');
			var $columns = $("#"+$raw+">td");
			if (!$("#updateInfo").length > 0) {
				var $div = $("<div id=\"updateInfo\"></div>")
				$(document.body).append($div);
				var $form = $("<form action=\"http://119.23.32.233:8888/student_info_manage_system/updateinfo\" method=\"Post\" id=\"submitInfo\"><form/>");
				$("#updateInfo").append($form);
				$("form").append("<p>student id\:</p>");
				$("form").append("<input type=\"text\" name=\"id\"/>");
				$("form").append("<p>student name\:</p>");
				$("form").append("<input type=\"text\" name=\"name\"/>");
				$("form").append("<p>student birthday\:</p>");
				$("form").append("<input type=\"text\" name=\"birthday\"/>");
				$("form").append("<p>student description\:</p>");
				$("form").append("<input type=\"text\" name=\"description\"/>");
				$("form").append("<p>student average score\:</p>");
				$("form").append("<input type=\"text\" name=\"avgScore\" value=\"0\"/>");
				$("form").append("<br/>");
				$("form").append("<input type=\"button\" onclick=\"isSubmit()\" value=\"提交\"/>");
				$("#updateInfo").append("<input type=\"button\" value=\"取消\" onclick=\"cancelUpdate()\"/>");
				<!-- 为input赋初值 -->
				$("input[name$='id']").val($columns.eq(0).html());
				$("input[name$='id']").attr("readonly",true);
				$("input[name$='name']").val($columns.eq(1).html());
				$("input[name$='birthday']").val($columns.eq(2).html());
				$("input[name$='description']").val($columns.eq(3).html());
				$("input[name$='avgScore']").val($columns.eq(4).html());
				<!-- 各输入框判断逻辑 -->
				$("input[name$='name']").focusout(function(e) {
					if ($(this).val() == "") {
						alert("请输入学生姓名！");
						$(this).val("");
					}
				});

				$("input[name$='avgScore']").focusout(function(e) {
					var $reg = /^\d+(\.{0,1}\d+){0,1}$/;
					if ($(this).val() != "0" && !$(this).val().match($reg)) {
						alert("请输入非负数！");
						$(this).val("");
					}
				});

				$("input[name$='birthday']").focusout(function(e) {
					var reg = /^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$/;
					if ($(this).val() != "") {
						if (!$(this).val().match(reg)) {
							alert("生日格式错误！格式应为YYYY-MM-DD");
							$(this).val("");
						}
					}
				});
			}
		});
	</script>
</body>
</html>