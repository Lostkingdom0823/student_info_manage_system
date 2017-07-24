package student_info_manage_system;

public class StudentInfo {
	public void setAvgScore(double avgScore) {
		this.avgScore = avgScore;
	}

	private String name;
	private String birthday;
	private String description;
	private double avgScore;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getBirthday() {
		return birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public double getAvgScore() {
		return avgScore;
	}

	public void setAvgScore(float avgScore) {
		this.avgScore = avgScore;
	}

	public StudentInfo(String name, String birthday, String description, double studentAvgScore) {
		this.name = name;
		this.birthday = birthday;
		this.description = description;
		this.avgScore = studentAvgScore;
	}
	public StudentInfo(){
		
	}
}
