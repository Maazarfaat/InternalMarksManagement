package com.vce.marks;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * StudentServlet handles student roll number lookup and retrieval of
 * student profile and internal assessment marks across all subjects.
 */
public class StudentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String rollNo = request.getParameter("roll_no");

        if (rollNo == null || rollNo.trim().isEmpty()) {
            // Initial view of student.jsp or empty submission
            request.getRequestDispatcher("/student.jsp").forward(request, response);
            return;
        }

        rollNo = rollNo.trim().toUpperCase();
        request.setAttribute("searchedRollNo", rollNo);

        String studentSql = "SELECT student_id, roll_no, name, section, department, semester "
                          + "FROM students WHERE UPPER(roll_no) = ?";

        String marksSql = "SELECT mark_id, subject, assessment, cat1_marks, cat2_marks, cat_average, "
                        + "       class_test_marks, assignment_marks, attendance_marks, total_internal_marks, updated_at "
                        + "FROM marks WHERE student_id = ? ORDER BY subject ASC, assessment ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement studentPs = conn.prepareStatement(studentSql)) {

            studentPs.setString(1, rollNo);

            try (ResultSet rs = studentPs.executeQuery()) {
                if (!rs.next()) {
                    request.setAttribute("errorMessage", "Student with Roll Number '" + rollNo + "' was not found.");
                    request.getRequestDispatcher("/student.jsp").forward(request, response);
                    return;
                }

                int studentId = rs.getInt("student_id");
                Map<String, Object> studentInfo = new HashMap<>();
                studentInfo.put("student_id", studentId);
                studentInfo.put("roll_no", rs.getString("roll_no"));
                studentInfo.put("name", rs.getString("name"));
                studentInfo.put("section", rs.getString("section"));
                studentInfo.put("department", rs.getString("department"));
                studentInfo.put("semester", rs.getInt("semester"));
                request.setAttribute("studentInfo", studentInfo);

                // Fetch student marks for all subjects
                List<Map<String, Object>> marksList = new ArrayList<>();
                try (PreparedStatement marksPs = conn.prepareStatement(marksSql)) {
                    marksPs.setInt(1, studentId);
                    try (ResultSet marksRs = marksPs.executeQuery()) {
                        while (marksRs.next()) {
                            Map<String, Object> m = new HashMap<>();
                            m.put("mark_id", marksRs.getInt("mark_id"));
                            m.put("subject", marksRs.getString("subject"));
                            m.put("assessment", marksRs.getString("assessment"));
                            m.put("cat1_marks", marksRs.getDouble("cat1_marks"));
                            m.put("cat2_marks", marksRs.getDouble("cat2_marks"));
                            m.put("cat_average", marksRs.getDouble("cat_average"));
                            m.put("class_test_marks", marksRs.getDouble("class_test_marks"));
                            m.put("assignment_marks", marksRs.getDouble("assignment_marks"));
                            m.put("attendance_marks", marksRs.getDouble("attendance_marks"));
                            m.put("total_internal_marks", marksRs.getDouble("total_internal_marks"));
                            m.put("updated_at", marksRs.getTimestamp("updated_at"));
                            marksList.add(m);
                        }
                    }
                }

                request.setAttribute("marksList", marksList);
                if (marksList.isEmpty()) {
                    request.setAttribute("infoMessage", "No marks have been recorded for this student yet.");
                }
            }

        } catch (Exception e) {
            System.err.println("Database error retrieving student data: " + e.getMessage());
            request.setAttribute("errorMessage", "Database error occurred while looking up student records.");
        }

        request.getRequestDispatcher("/student.jsp").forward(request, response);
    }
}
