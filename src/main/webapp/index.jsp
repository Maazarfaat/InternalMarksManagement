<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If faculty is already authenticated, redirect to dashboard
    if (session.getAttribute("facultyId") != null) {
        response.sendRedirect(request.getContextPath() + "/faculty.jsp");
        return;
    }
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Login - Internal Marks Management System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header class="header">
        <div class="header-container">
            <a href="<%= request.getContextPath() %>/index.jsp" class="brand">
                <div class="brand-icon">IM</div>
                <div class="brand-text">
                    <h1>Internal Marks Management System</h1>
                    <p>Department of Information Technology &bull; VCE</p>
                </div>
            </a>
            <div class="nav-actions">
                <a href="<%= request.getContextPath() %>/student.jsp" class="btn btn-secondary btn-sm">
                    Student Marks Portal &rarr;
                </a>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div class="login-wrapper">

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-error">
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="alert alert-success">
                    <span><%= msg %></span>
                </div>
            <% } %>

            <div class="login-card">
                <div class="login-header">
                    <h2>Faculty Login</h2>
                    <p>Enter your faculty credentials to manage student internal assessment marks.</p>
                </div>

                <form id="loginForm" action="<%= request.getContextPath() %>/login" method="POST">
                    <div class="form-group">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" id="username" name="username" class="form-control" placeholder="Enter username" required autofocus>
                    </div>

                    <div class="form-group">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="Enter password" required>
                    </div>

                    <div class="form-group" style="margin-top: 1.5rem;">
                        <button type="submit" class="btn btn-primary" style="width: 100%;">
                            Sign In to Faculty Dashboard
                        </button>
                    </div>
                </form>

                <div class="demo-credentials-box">
                    <strong>Demo Faculty Credentials:</strong><br>
                    Username: <code>faculty</code> &bull; Password: <code>faculty123</code>
                    <button type="button" class="btn btn-secondary btn-sm" onclick="quickFacultyLogin()" style="margin-top: 0.6rem; width: 100%;">
                        &#9889; 1-Click Auto Fill &amp; Sign In
                    </button>
                </div>

                <div style="margin-top: 1.5rem; text-align: center; font-size: 0.875rem;">
                    Are you a student? 
                    <a href="<%= request.getContextPath() %>/student.jsp" style="color: var(--accent); font-weight: 600; text-decoration: none;">
                        View Your Marks Here &rarr;
                    </a>
                </div>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p><strong>Web Technologies Course-End Project (A8605)</strong> &bull; Team 24WT-45 &bull; Vardhaman College of Engineering</p>
        <p style="font-size: 0.8rem; opacity: 0.85; margin-top: 0.25rem;">
            Mohammed Maaz Arfaat (24881A1245) &bull; Nadikuda Sathish (24881A12B0) &bull; Saddi Amulya Reddy (24881A12H3)
        </p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
