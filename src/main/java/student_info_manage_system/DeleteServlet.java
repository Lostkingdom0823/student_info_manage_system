package student_info_manage_system;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redis.clients.jedis.Jedis;

public class DeleteServlet extends HttpServlet{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String studentId = request.getParameter("id");
		
		@SuppressWarnings("resource")
		Jedis jedis =new Jedis("119.23.32.233",6379);
		if(jedis.hdel("student_info", studentId)==1){
			if(jedis.zrem("sorted_id", studentId)==1){
				response.sendRedirect("http://119.23.32.233:8888/student_info_manage_system/manage.jsp?contentPage=1");
			}
		}
		else {
			response.sendRedirect("http://119.23.32.233:8888/student_info_manage_system/manage.jsp");
		}
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
	}
	
}
