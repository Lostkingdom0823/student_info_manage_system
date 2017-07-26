package student_info_manage_system;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONObject;
import redis.clients.jedis.Jedis;

public class UpdateServlet extends HttpServlet{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String studentId = request.getParameter("id");
		String studentName = new String(request.getParameter("name").getBytes("iso-8859-1"), "utf-8"); 
		String studentBirthday  = request.getParameter("birthday");
		String studentDescription =new String(request.getParameter("description").getBytes("iso-8859-1"),"utf-8");
		double studentAvgScore = Double.parseDouble(request.getParameter("avgScore"));
		
		StudentInfo studentInfo = new StudentInfo(studentName, studentBirthday, studentDescription, studentAvgScore);
		JSONObject jsonObject = JSONObject.fromObject(studentInfo);
		@SuppressWarnings("resource")
		Jedis jedis = new Jedis("119.23.32.233",6379);
		if(jedis.hget("student_info", studentId).equals("nil")){
		}
		else {
			jedis.zadd("sorted_id", studentAvgScore, studentId);
			jedis.hset("student_info", studentId, jsonObject.toString());
			response.sendRedirect("http://119.23.32.233:8888/student_info_manage_system/manage.jsp?contentPage=1");
		}
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
	}
	
	
}
