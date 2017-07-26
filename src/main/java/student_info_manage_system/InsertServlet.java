package student_info_manage_system;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.*;
import redis.clients.jedis.Jedis;

public class InsertServlet extends HttpServlet{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String studentId = request.getParameter("id");
		String studentName = new String(request.getParameter("name").getBytes("iso-8859-1"), "utf-8"); 
		String studentDescription = new String(request.getParameter("description").getBytes("iso-8859-1"), "utf-8");
		System.out.println(studentDescription);
		String studentBirthday = request.getParameter("birthday");
		double studentAvgScore = Double.parseDouble(request.getParameter("avgScore"));
		response.getWriter().println("<br/>");
		StudentInfo studentInfo = new StudentInfo(studentName, studentBirthday, studentDescription, studentAvgScore);
		JSONObject jsonObject = JSONObject.fromObject(studentInfo);
		@SuppressWarnings("resource")
		Jedis jedis = new Jedis("119.23.32.233",6379);
		if(jedis.zadd("sorted_id", studentAvgScore, studentId)==1){
			if(jedis.hsetnx("student_info", studentId, jsonObject.toString())==1){
				response.sendRedirect("http://119.23.32.233:8888/student_info_manage_system/manage.jsp?contentPage=1");
			}
		}
		else {
			
		}
	}
	@Override
	public void init(ServletConfig config) throws ServletException {
	}
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	}
}
