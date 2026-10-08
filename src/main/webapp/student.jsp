<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String searchedRollNo = (String) request.getAttribute("searchedRollNo");
    if (searchedRollNo == null) searchedRollNo = "";

    Map<String, Object> studentInfo = (Map<String, Object>) request.getAttribute("studentInfo");
    List<Map<String, Object>> marksList = (List<Map<String, Object>>) request.getAttribute("marksList");

    String errorMessage = (String) request.getAttribute("errorMessage");
    String infoMessage = (String) request.getAttribute("infoMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Marks Portal - Internal Marks Management System</title>
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
                <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-secondary btn-sm">
                    &larr; Faculty Login
                </a>
            </div>
        </div>
    </header>

    <main class="main-content">

        <div class="card student-search-box">
            <div class="card-title" style="text-align: center; justify-content: center;">
                <h2>Student Internal Marks Portal</h2>
            </div>
            <p style="text-align: center; color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">
                Enter your official university Roll Number to retrieve and view your verified internal assessment marks across all subjects.
            </p>

            <form id="studentSearchForm" action="<%= request.getContextPath() %>/student" method="GET">
                <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
                    <input type="text" id="studentRollInput" name="roll_no" class="form-control" 
                           placeholder="Enter Roll Number (e.g., 24881A1245, 24881A12B0, 24881A12H3)" 
                           value="<%= searchedRollNo %>" required autofocus
                           style="flex: 1; text-transform: uppercase;">
                    <button type="submit" class="btn btn-primary">
                        VIEW MARKS
                    </button>
                </div>
                <div class="quick-roll-tags">
                    <span class="quick-roll-label">Quick Demo Roll:</span>
                    <button type="button" class="roll-pill" onclick="selectDemoRoll('24881A1245')">24881A1245 (Mohammed Maaz - Sec A)</button>
                    <button type="button" class="roll-pill" onclick="selectDemoRoll('24881A12B0')">24881A12B0 (Nadikuda Sathish - Sec B)</button>
                    <button type="button" class="roll-pill" onclick="selectDemoRoll('24881A12H3')">24881A12H3 (Saddi Amulya - Sec C)</button>
                    <button type="button" class="roll-pill" onclick="selectDemoRoll('24881A1201')">24881A1201 (Sec A)</button>
                </div>
            </form>
        </div>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="alert alert-error" style="max-width: 960px; margin: 0 auto 1.5rem auto;">
                <span><%= errorMessage %></span>
            </div>
        <% } %>

        <% if (infoMessage != null && !infoMessage.trim().isEmpty()) { %>
            <div class="alert alert-info" style="max-width: 960px; margin: 0 auto 1.5rem auto;">
                <span><%= infoMessage %></span>
            </div>
        <% } %>

        <% if (studentInfo != null) { %>
            <div class="card" style="max-width: 960px; margin: 0 auto 1.5rem auto;">
                <div class="card-title">
                    <span>Student Profile</span>
                    <div style="display: flex; align-items: center; gap: 0.75rem;">
                        <span style="font-size: 0.85rem; color: var(--text-muted); font-weight: normal;">Verified University Record</span>
                        <button type="button" onclick="window.print()" class="btn btn-secondary btn-sm" title="Print this official mark statement">
                            &#128424; Print Statement
                        </button>
                    </div>
                </div>

                <div class="student-info-grid">
                    <div class="info-item">
                        <span class="info-label">Student Name</span>
                        <span class="info-value"><%= studentInfo.get("name") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Roll Number</span>
                        <span class="info-value col-roll" style="font-size: 1.1rem;"><%= studentInfo.get("roll_no") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Section</span>
                        <span class="info-value">Section <%= studentInfo.get("section") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Department</span>
                        <span class="info-value"><%= studentInfo.get("department") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Semester</span>
                        <span class="info-value">Semester <%= studentInfo.get("semester") %></span>
                    </div>
                </div>

                <div class="card-title" style="margin-top: 1.5rem;">
                    <span>Internal Assessment Marks (Out of 40)</span>
                </div>

                <% if (marksList != null && !marksList.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="student-marks-table">
                            <thead>
                                <tr>
                                    <th>Subject</th>
                                    <th style="text-align: center;">CAT 1<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 30)</span></th>
                                    <th style="text-align: center;">CAT 2<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 30)</span></th>
                                    <th style="text-align: center;">CAT Avg<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 30)</span></th>
                                    <th style="text-align: center;">Class Tests<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 4)</span></th>
                                    <th style="text-align: center;">Assignments<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 4)</span></th>
                                    <th style="text-align: center;">Attendance<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 2)</span></th>
                                    <th style="text-align: center;">Internal Total<br><span style="font-size: 0.7rem; font-weight: normal;">(Max: 40)</span></th>
                                    <th style="text-align: center;">Academic Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> m : marksList) { 
                                    double tot = (Double) m.get("total_internal_marks");
                                    String statusClass = "status-distinction";
                                    String statusLabel = "Distinction";
                                    if (tot >= 32.0) {
                                        statusClass = "status-distinction";
                                        statusLabel = "Distinction";
                                    } else if (tot >= 24.0) {
                                        statusClass = "status-firstclass";
                                        statusLabel = "First Class";
                                    } else if (tot >= 16.0) {
                                        statusClass = "status-pass";
                                        statusLabel = "Pass";
                                    } else if (tot > 0) {
                                        statusClass = "status-remedial";
                                        statusLabel = "Remedial";
                                    } else {
                                        statusClass = "status-pending";
                                        statusLabel = "Pending";
                                    }
                                %>
                                    <tr>
                                        <td><strong><%= m.get("subject") %></strong></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("cat1_marks")) %></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("cat2_marks")) %></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("cat_average")) %></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("class_test_marks")) %></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("assignment_marks")) %></td>
                                        <td style="text-align: center;"><%= String.format("%.2f", (Double) m.get("attendance_marks")) %></td>
                                        <td style="text-align: center;">
                                            <span class="total-score-badge">
                                                <%= String.format("%.2f", tot) %> / 40.0
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="status-badge <%= statusClass %>"><%= statusLabel %></span>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div style="text-align: center; padding: 2rem; background: #f8fafc; border-radius: var(--radius-md); border: 1px dashed var(--border);">
                        <p style="color: var(--text-muted); font-size: 0.95rem;">
                            No internal assessment marks have been entered for this student yet.
                        </p>
                    </div>
                <% } %>
            </div>
        <% } %>

    </main>

    <footer class="footer">
        <p>Web Technologies Course-End Project (A8605) &bull; Vardhaman College of Engineering</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
