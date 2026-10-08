package com.vce.marks;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * LoginServlet handles faculty authentication and session invalidation (logout).
 */
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/index.jsp?msg=Logged+out+successfully");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/index.jsp?msg=Logged+out+successfully");
            return;
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Username+and+password+are+required");
            return;
        }

        username = username.trim();
        password = password.trim();

        String sql = "SELECT faculty_id, username, name FROM faculty WHERE username = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("facultyId", rs.getInt("faculty_id"));
                    session.setAttribute("facultyUser", rs.getString("username"));
                    session.setAttribute("facultyName", rs.getString("name"));

                    response.sendRedirect(request.getContextPath() + "/faculty.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/index.jsp?error=Invalid+username+or+password");
                }
            }

        } catch (Exception e) {
            System.err.println("Database error during faculty login: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Database+error+occurred.+Please+try+again.");
        }
    }
}
