<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%
    // Session protection - only authenticated faculty can access
    if (session.getAttribute("facultyId") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.+Please+log+in+first.");
        return;
    }

    // Auto-load default Section A if no student list is currently in the request
    List<Map<String, Object>> studentList = (List<Map<String, Object>>) request.getAttribute("studentList");
    if (studentList == null) {
        response.sendRedirect(request.getContextPath() + "/marks?action=load&branch=IT&section=A");
        return;
    }

    String facultyName = (String) session.getAttribute("facultyName");
    String facultyUser = (String) session.getAttribute("facultyUser");

    String selectedBranch = (String) request.getAttribute("selectedBranch");
    if (selectedBranch == null) selectedBranch = "IT";

    String selectedSection = (String) request.getAttribute("selectedSection");
    if (selectedSection == null) selectedSection = "A";

    String selectedSubject = (String) request.getAttribute("selectedSubject");
    if (selectedSubject == null) selectedSubject = "Web Technologies";

    String selectedAssessment = (String) request.getAttribute("selectedAssessment");
    if (selectedAssessment == null) selectedAssessment = "Internal Assessment 1";

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");

    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "manual";

    Map<String, Object> importSummary = (Map<String, Object>) request.getAttribute("importSummary");
    List<Map<String, Object>> rowErrors = (List<Map<String, Object>>) request.getAttribute("rowErrors");
    List<com.vce.marks.MarksServlet.ExcelRowData> previewRows = (List<com.vce.marks.MarksServlet.ExcelRowData>) request.getAttribute("previewRows");
    Boolean isPreview = (Boolean) request.getAttribute("isPreview");
    if (isPreview == null) isPreview = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Dashboard - Internal Marks Management System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header class="header">
        <div class="header-container">
            <a href="<%= request.getContextPath() %>/faculty.jsp" class="brand">
                <div class="brand-icon">IM</div>
                <div class="brand-text">
                    <h1>Internal Marks Management System</h1>
                    <p>Continuous Internal Evaluation &bull; Vardhaman College of Engineering</p>
                </div>
            </a>
            <div class="nav-actions">
                <span class="faculty-badge">
                    Faculty: <strong><%= facultyName != null ? facultyName : facultyUser %></strong>
                </span>
                <a href="<%= request.getContextPath() %>/login?action=logout" class="btn btn-danger btn-sm">
                    Logout
                </a>
            </div>
        </div>
    </header>

    <main class="main-content">

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <span><%= successMessage %></span>
            </div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <span><%= errorMessage %></span>
            </div>
        <% } %>

        <!-- Branch, Section, Subject, and Assessment Selection Bar -->
        <form id="filterForm" action="<%= request.getContextPath() %>/marks" method="GET" class="controls-bar">
            <input type="hidden" name="action" value="load">

            <div class="control-item">
                <label for="branchSelect" class="form-label">Select Branch</label>
                <select id="branchSelect" name="branch" class="form-control" onchange="onFilterBranchChange(); this.form.submit();">
                    <option value="IT" <%= "IT".equals(selectedBranch) ? "selected" : "" %>>IT (Information Tech)</option>
                    <option value="CSE" <%= "CSE".equals(selectedBranch) ? "selected" : "" %>>CSE (Computer Science)</option>
                    <option value="CSM" <%= "CSM".equals(selectedBranch) ? "selected" : "" %>>CSM (CSE - AI &amp; ML)</option>
                    <option value="CSD" <%= "CSD".equals(selectedBranch) ? "selected" : "" %>>CSD (CSE - Data Science)</option>
                    <option value="ECE" <%= "ECE".equals(selectedBranch) ? "selected" : "" %>>ECE (Electronics &amp; Comm)</option>
                    <option value="EEE" <%= "EEE".equals(selectedBranch) ? "selected" : "" %>>EEE (Electrical &amp; Electronics)</option>
                    <option value="MECH" <%= "MECH".equals(selectedBranch) ? "selected" : "" %>>MECH (Mechanical Engg)</option>
                    <option value="CIVIL" <%= "CIVIL".equals(selectedBranch) ? "selected" : "" %>>CIVIL (Civil Engg)</option>
                </select>
            </div>

            <div class="control-item">
                <label for="sectionSelect" class="form-label">Select Section</label>
                <select id="sectionSelect" name="section" class="form-control" onchange="this.form.submit()">
                    <%
                        List<String> curSections = com.vce.marks.MarksServlet.BRANCH_SECTIONS.get(selectedBranch);
                        if (curSections == null) curSections = java.util.Arrays.asList("A", "B", "C");
                        for (String sec : curSections) {
                    %>
                        <option value="<%= sec %>" <%= sec.equals(selectedSection) ? "selected" : "" %>>Section <%= sec %></option>
                    <% } %>
                </select>
            </div>

            <div class="control-item">
                <label for="subjectSelect" class="form-label">Course / Subject</label>
                <select id="subjectSelect" name="subject" class="form-control" onchange="this.form.submit()">
                    <option value="Web Technologies" <%= "Web Technologies".equals(selectedSubject) ? "selected" : "" %>>Web Technologies</option>
                    <option value="Data Science" <%= "Data Science".equals(selectedSubject) ? "selected" : "" %>>Data Science</option>
                    <option value="Software Engineering" <%= "Software Engineering".equals(selectedSubject) ? "selected" : "" %>>Software Engineering</option>
                    <option value="Computer Networks" <%= "Computer Networks".equals(selectedSubject) ? "selected" : "" %>>Computer Networks</option>
                    <option value="Machine Learning" <%= "Machine Learning".equals(selectedSubject) ? "selected" : "" %>>Machine Learning</option>
                </select>
            </div>

            <div class="control-item">
                <label for="assessmentSelect" class="form-label">Assessment Type</label>
                <select id="assessmentSelect" name="assessment" class="form-control" onchange="this.form.submit()">
                    <option value="Internal Assessment 1" selected>Internal Assessment 1</option>
                </select>
            </div>

            <div class="control-item">
                <label class="form-label">&nbsp;</label>
                <button type="submit" class="btn btn-primary" style="height: 40px;">
                    Load Students
                </button>
            </div>
        </form>

        <!-- Mode Navigation Tabs -->
        <div class="faculty-tabs">
            <button type="button" class="tab-btn <%= !"excel".equals(activeTab) ? "active" : "" %>" id="tabManualBtn" onclick="switchFacultyTab('manual')">
                &#128221; Manual Marks Entry
            </button>
            <button type="button" class="tab-btn <%= "excel".equals(activeTab) ? "active" : "" %>" id="tabExcelBtn" onclick="switchFacultyTab('excel')">
                &#128202; Excel Bulk Import (.xlsx)
                <% if (importSummary != null) { %>
                    <span class="tab-badge">&#9679; Results</span>
                <% } %>
            </button>
        </div>

        <!-- TAB 1: MANUAL MARKS ENTRY PANEL -->
        <div id="manualEntryPanel" style="<%= "excel".equals(activeTab) ? "display: none;" : "display: block;" %>">

            <!-- Performance KPI Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">&#128101;</div>
                    <div class="stat-content">
                        <span class="stat-label">Total Students</span>
                        <span class="stat-value" id="kpiTotalStudents"><%= studentList.size() %></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">&#128200;</div>
                    <div class="stat-content">
                        <span class="stat-label">Class Average</span>
                        <span class="stat-value" id="kpiClassAvg">0.00 / 40</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">&#127942;</div>
                    <div class="stat-content">
                        <span class="stat-label">Highest Score</span>
                        <span class="stat-value" id="kpiHighestScore">0.00 / 40</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">&#9989;</div>
                    <div class="stat-content">
                        <span class="stat-label">Distinction (&ge; 32)</span>
                        <span class="stat-value" id="kpiDistinction">0</span>
                    </div>
                </div>
            </div>

            <!-- Main Marks Entry Form -->
            <form id="marksEntryForm" action="<%= request.getContextPath() %>/marks" method="POST">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="branch" value="<%= selectedBranch %>">
                <input type="hidden" name="section" value="<%= selectedSection %>">
                <input type="hidden" name="subject" value="<%= selectedSubject %>">
                <input type="hidden" name="assessment" value="<%= selectedAssessment %>">

                <div class="table-toolbar">
                    <div class="search-box">
                        <span class="search-icon">&#128269;</span>
                        <input type="text" id="studentSearch" class="search-input" placeholder="Search by Roll No or Student Name...">
                    </div>

                    <div class="table-stats">
                        <span id="visibleCountDisplay">Showing <%= studentList.size() %> of <%= studentList.size() %> students</span>
                        &bull; Branch: <strong><%= selectedBranch %></strong>
                        &bull; Section: <strong><%= selectedSection %></strong>
                        &bull; Subject: <strong><%= selectedSubject %></strong>
                    </div>

                    <div class="toolbar-btn-group">
                        <button type="button" id="btnFillDemo" class="btn btn-secondary btn-sm" title="Auto-fill realistic marks for unentered students">
                            &#9889; Fill Sample Marks
                        </button>
                        <button type="button" id="btnExportCsv" class="btn btn-secondary btn-sm" title="Export this marksheet to CSV spreadsheet">
                            &#128196; Export CSV
                        </button>
                        <button type="button" onclick="window.print()" class="btn btn-secondary btn-sm" title="Print this official marksheet">
                            &#128424; Print
                        </button>
                        <button type="submit" class="btn btn-success btn-sm">
                            &#128190; SAVE ALL MARKS
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table id="marksTable" class="marks-table">
                        <thead>
                            <tr>
                                <th style="width: 45px;">#</th>
                                <th style="width: 120px;">Roll Number</th>
                                <th>Student Name</th>
                                <th style="text-align: center; width: 85px;">
                                    CAT 1
                                    <span class="max-hint">(Max: 30)</span>
                                </th>
                                <th style="text-align: center; width: 85px;">
                                    CAT 2
                                    <span class="max-hint">(Max: 30)</span>
                                </th>
                                <th style="text-align: center; width: 90px;">
                                    CAT Avg
                                    <span class="max-hint">(Max: 30)</span>
                                </th>
                                <th style="text-align: center; width: 90px;">
                                    Class Tests
                                    <span class="max-hint">(Max: 4)</span>
                                </th>
                                <th style="text-align: center; width: 90px;">
                                    Assignments
                                    <span class="max-hint">(Max: 4)</span>
                                </th>
                                <th style="text-align: center; width: 85px;">
                                    Attendance
                                    <span class="max-hint">(Max: 2)</span>
                                </th>
                                <th style="text-align: center; width: 95px;">
                                    Internal Total
                                    <span class="max-hint">(Max: 40)</span>
                                </th>
                                <th style="text-align: center; width: 110px;">
                                    Status
                                    <span class="max-hint">(Academic)</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (studentList.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="11" style="text-align: center; padding: 2.5rem; color: var(--text-muted);">
                                        No student records found in <%= selectedBranch %> Section <%= selectedSection %>.
                                        Use the <strong>Excel Bulk Import</strong> tab to upload and create student records.
                                    </td>
                                </tr>
                            <%
                                } else {
                                    int index = 1;
                                    for (Map<String, Object> s : studentList) {
                                        int studentId = (Integer) s.get("student_id");
                                        String rollNo = (String) s.get("roll_no");
                                        String name = (String) s.get("name");
                                        double cat1 = (Double) s.get("cat1_marks");
                                        double cat2 = (Double) s.get("cat2_marks");
                                        double catAvg = (Double) s.get("cat_average");
                                        double classTest = (Double) s.get("class_test_marks");
                                        double assign = (Double) s.get("assignment_marks");
                                        double att = (Double) s.get("attendance_marks");
                                        double total = (Double) s.get("total_internal_marks");
                            %>
                                <tr>
                                    <td style="color: var(--text-muted);"><%= index++ %></td>
                                    <td class="col-roll">
                                        <%= rollNo %>
                                        <input type="hidden" name="student_id" value="<%= studentId %>">
                                    </td>
                                    <td class="col-name col-readonly"><%= name %></td>
                                    <td style="text-align: center;">
                                        <input type="number" step="0.5" min="0" max="30" 
                                               name="cat1_marks" class="mark-input" data-type="cat1"
                                               value="<%= cat1 %>" required>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="number" step="0.5" min="0" max="30" 
                                               name="cat2_marks" class="mark-input" data-type="cat2"
                                               value="<%= cat2 %>" required>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="text" class="cat-avg-input" value="<%= String.format("%.2f", catAvg) %>" readonly>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="number" step="0.5" min="0" max="4" 
                                               name="class_test_marks" class="mark-input" data-type="class_test"
                                               value="<%= classTest %>" required>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="number" step="0.5" min="0" max="4" 
                                               name="assignment_marks" class="mark-input" data-type="assignment"
                                               value="<%= assign %>" required>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="number" step="0.5" min="0" max="2" 
                                               name="attendance_marks" class="mark-input" data-type="attendance"
                                               value="<%= att %>" required>
                                    </td>
                                    <td style="text-align: center;">
                                        <input type="text" class="total-input" value="<%= String.format("%.2f", total) %>" readonly>
                                    </td>
                                    <td style="text-align: center;" class="col-status">
                                        <span class="status-badge status-pending">Pending</span>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <div style="margin-top: 1.5rem; display: flex; justify-content: flex-end; gap: 0.75rem;">
                    <button type="button" onclick="window.print()" class="btn btn-secondary btn-lg">
                        &#128424; Print Mark Sheet
                    </button>
                    <button type="submit" class="btn btn-success btn-lg">
                        &#128190; SAVE ALL MARKS
                    </button>
                </div>
            </form>
        </div>

        <!-- TAB 2: EXCEL BULK IMPORT PANEL -->
        <div id="excelImportPanel" class="excel-panel" style="<%= !"excel".equals(activeTab) ? "display: none;" : "display: block;" %>">

            <div class="card" style="margin-bottom: 0;">
                <div class="card-title">
                    <span>&#128202; Excel Marks Bulk Import (.xlsx)</span>
                    <a href="<%= request.getContextPath() %>/marks?action=download_template&branch=<%= selectedBranch %>&section=<%= selectedSection %>&subject=<%= java.net.URLEncoder.encode(selectedSubject, "UTF-8") %>" 
                       class="btn btn-secondary btn-sm" id="btnDownloadTemplate" data-context="<%= request.getContextPath() %>"
                       title="Download an official .xlsx template formatted with required columns">
                        &#128229; Download Excel Template (.xlsx)
                    </a>
                </div>

                <!-- Active Target Info Bar -->
                <div class="excel-target-bar">
                    <span class="excel-target-item">Target Branch: <strong id="excelTargetBranch"><%= selectedBranch %></strong></span>
                    <span class="excel-target-item">Target Section: <strong id="excelTargetSection">Section <%= selectedSection %></strong></span>
                    <span class="excel-target-item">Target Subject: <strong id="excelTargetSubject"><%= selectedSubject %></strong></span>
                    <span class="excel-target-item">Assessment: <strong>Internal Assessment 1</strong></span>
                </div>

                <!-- Excel Upload & Configuration Form -->
                <form id="excelUploadForm" action="<%= request.getContextPath() %>/marks" method="POST" enctype="multipart/form-data" class="excel-upload-form" style="margin-top: 1.25rem;">
                    <input type="hidden" name="action" id="excelActionInput" value="import_excel">

                    <div class="excel-form-grid">
                        <div class="form-group">
                            <label for="excelBranchSelect" class="form-label">Select Branch</label>
                            <select id="excelBranchSelect" name="branch" class="form-control" onchange="onExcelBranchChange()">
                                <option value="IT" <%= "IT".equals(selectedBranch) ? "selected" : "" %>>IT (Information Tech)</option>
                                <option value="CSE" <%= "CSE".equals(selectedBranch) ? "selected" : "" %>>CSE (Computer Science)</option>
                                <option value="CSM" <%= "CSM".equals(selectedBranch) ? "selected" : "" %>>CSM (CSE - AI &amp; ML)</option>
                                <option value="CSD" <%= "CSD".equals(selectedBranch) ? "selected" : "" %>>CSD (CSE - Data Science)</option>
                                <option value="ECE" <%= "ECE".equals(selectedBranch) ? "selected" : "" %>>ECE (Electronics &amp; Comm)</option>
                                <option value="EEE" <%= "EEE".equals(selectedBranch) ? "selected" : "" %>>EEE (Electrical &amp; Electronics)</option>
                                <option value="MECH" <%= "MECH".equals(selectedBranch) ? "selected" : "" %>>MECH (Mechanical Engg)</option>
                                <option value="CIVIL" <%= "CIVIL".equals(selectedBranch) ? "selected" : "" %>>CIVIL (Civil Engg)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="excelSectionSelect" class="form-label">Select Section</label>
                            <select id="excelSectionSelect" name="section" class="form-control" onchange="updateTemplateDownloadLink()">
                                <%
                                    List<String> curExcelSections = com.vce.marks.MarksServlet.BRANCH_SECTIONS.get(selectedBranch);
                                    if (curExcelSections == null) curExcelSections = java.util.Arrays.asList("A", "B", "C");
                                    for (String sec : curExcelSections) {
                                %>
                                    <option value="<%= sec %>" <%= sec.equals(selectedSection) ? "selected" : "" %>>Section <%= sec %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="excelSubjectSelect" class="form-label">Select Subject</label>
                            <select id="excelSubjectSelect" name="subject" class="form-control" onchange="updateTemplateDownloadLink()">
                                <option value="Web Technologies" <%= "Web Technologies".equals(selectedSubject) ? "selected" : "" %>>Web Technologies</option>
                                <option value="Data Science" <%= "Data Science".equals(selectedSubject) ? "selected" : "" %>>Data Science</option>
                                <option value="Software Engineering" <%= "Software Engineering".equals(selectedSubject) ? "selected" : "" %>>Software Engineering</option>
                                <option value="Computer Networks" <%= "Computer Networks".equals(selectedSubject) ? "selected" : "" %>>Computer Networks</option>
                                <option value="Machine Learning" <%= "Machine Learning".equals(selectedSubject) ? "selected" : "" %>>Machine Learning</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="excelFileInput" class="form-label">Choose Excel File (.xlsx)</label>
                            <input type="file" id="excelFileInput" name="excelFile" class="form-control file-input" accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" required>
                        </div>
                    </div>

                    <div class="excel-actions-bar">
                        <button type="button" onclick="submitExcelPreview()" class="btn btn-secondary btn-md" id="btnPreviewExcel" title="Validate and preview rows without modifying the database">
                            &#128269; Preview / Validate File
                        </button>
                        <button type="button" onclick="submitExcelImport()" class="btn btn-primary btn-md" id="btnImportExcel" title="Validate, import student marks, and update MySQL">
                            &#128640; Import &amp; Update MySQL
                        </button>
                    </div>
                </form>

                <!-- Import Summary Metrics -->
                <% if (importSummary != null) { %>
                    <div style="margin-top: 1.5rem;">
                        <h3 style="font-size: 1rem; color: var(--dark); margin-bottom: 0.75rem;">Import Validation Summary</h3>
                        <div class="excel-summary-grid">
                            <div class="excel-summary-card total">
                                <span class="summary-stat-label">Total Rows Evaluated</span>
                                <span class="summary-stat-value"><%= importSummary.get("totalRows") %></span>
                            </div>
                            <div class="excel-summary-card success">
                                <span class="summary-stat-label"><%= isPreview ? "Valid Rows (Ready to Import)" : "Successful Records Updated" %></span>
                                <span class="summary-stat-value"><%= importSummary.get("successRows") %></span>
                            </div>
                            <div class="excel-summary-card failed">
                                <span class="summary-stat-label"><%= isPreview ? "Invalid Rows (Rejected)" : "Failed / Rejected Rows" %></span>
                                <span class="summary-stat-value"><%= importSummary.get("failedRows") %></span>
                            </div>
                        </div>
                    </div>
                <% } %>

                <!-- Row-Wise Validation Error Report -->
                <% if (rowErrors != null && !rowErrors.isEmpty()) { %>
                    <div class="excel-error-box">
                        <div class="excel-error-title">
                            <span>&#9888; Row-Wise Validation Errors (<%= rowErrors.size() %> row(s) rejected)</span>
                        </div>
                        <div class="table-responsive">
                            <table class="excel-error-table">
                                <thead>
                                    <tr>
                                        <th style="width: 70px;">Row #</th>
                                        <th style="width: 140px;">Roll Number</th>
                                        <th style="width: 200px;">Student Name</th>
                                        <th>Reason for Rejection / Validation Issue</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> err : rowErrors) { %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= err.get("rowNum") %></td>
                                            <td><code><%= err.get("rollNo") %></code></td>
                                            <td><%= err.get("name") %></td>
                                            <td style="color: var(--error);"><%= err.get("errors") %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } %>

                <!-- Preview / Confirmation Table -->
                <% if (previewRows != null && !previewRows.isEmpty() && isPreview) { %>
                    <div style="margin-top: 1.5rem; background: #ffffff; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 1.25rem;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.75rem;">
                            <div>
                                <h3 style="font-size: 1rem; color: var(--dark); margin: 0;">Parsed Rows Preview</h3>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin: 0.25rem 0 0 0;">
                                    Review the parsed records below. No modifications have been saved to MySQL yet.
                                </p>
                            </div>
                            <% if (importSummary != null && (Integer) importSummary.get("successRows") > 0) { %>
                                <form action="<%= request.getContextPath() %>/marks" method="POST" style="margin: 0;">
                                    <input type="hidden" name="action" value="confirm_import">
                                    <button type="submit" class="btn btn-success btn-md">
                                        &#128640; Confirm &amp; Import <%= importSummary.get("successRows") %> Valid Rows to MySQL
                                    </button>
                                </form>
                            <% } %>
                        </div>

                        <div class="table-responsive">
                            <table class="marks-table" style="font-size: 0.875rem;">
                                <thead>
                                    <tr>
                                        <th style="width: 60px;">Row #</th>
                                        <th>Roll Number</th>
                                        <th>Student Name</th>
                                        <th style="text-align: center;">CAT 1<br>(Max: 30)</th>
                                        <th style="text-align: center;">CAT 2<br>(Max: 30)</th>
                                        <th style="text-align: center;">CAT Avg<br>(Max: 30)</th>
                                        <th style="text-align: center;">Class Tests<br>(Max: 4)</th>
                                        <th style="text-align: center;">Assignments<br>(Max: 4)</th>
                                        <th style="text-align: center;">Attendance<br>(Max: 2)</th>
                                        <th style="text-align: center;">Internal Total<br>(Max: 40)</th>
                                        <th style="text-align: center; width: 100px;">Validation</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (com.vce.marks.MarksServlet.ExcelRowData r : previewRows) { %>
                                        <tr style="<%= !r.isValid() ? "background-color: #fef2f2;" : "" %>">
                                            <td><%= r.getRowNum() %></td>
                                            <td><code><%= r.getRollNo() %></code></td>
                                            <td>
                                                <%= r.getName() %>
                                                <% if (r.isNewStudent()) { %>
                                                    <span style="font-size: 0.725rem; color: var(--accent); font-weight: 600;">(New Student)</span>
                                                <% } %>
                                            </td>
                                            <td style="text-align: center;"><%= r.getCat1() %></td>
                                            <td style="text-align: center;"><%= r.getCat2() %></td>
                                            <td style="text-align: center; font-weight: 600;"><%= String.format("%.2f", r.getCatAverage()) %></td>
                                            <td style="text-align: center;"><%= r.getClassTest() %></td>
                                            <td style="text-align: center;"><%= r.getAssignment() %></td>
                                            <td style="text-align: center;"><%= r.getAttendance() %></td>
                                            <td style="text-align: center; font-weight: 700; color: var(--primary);"><%= String.format("%.2f", r.getTotal()) %></td>
                                            <td style="text-align: center;">
                                                <% if (r.isValid()) { %>
                                                    <span class="preview-status-badge preview-status-valid">&#10004; Valid</span>
                                                <% } else { %>
                                                    <span class="preview-status-badge preview-status-invalid" title="<%= String.join("; ", r.getErrors()) %>">&#10008; Rejected</span>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } %>

                <!-- Post-Import Action: Quick Switch to Manual View -->
                <% if (!isPreview && importSummary != null && (Integer) importSummary.get("successRows") > 0) { %>
                    <div style="margin-top: 1.5rem; text-align: center; padding: 1.25rem; background: var(--success-bg); border: 1px solid var(--success-border); border-radius: var(--radius-md);">
                        <p style="color: var(--success); font-weight: 600; margin-bottom: 0.75rem;">
                            &#10004; Database records have been updated in MySQL!
                        </p>
                        <button type="button" onclick="switchFacultyTab('manual')" class="btn btn-primary btn-md">
                            &#128065; Switch to Manual Entry to View Marksheet
                        </button>
                    </div>
                <% } %>

            </div>

            <!-- Guidelines and Rules Card -->
            <div class="excel-guide-box">
                <h4>&#128218; Excel Import Guidelines &amp; Academic Rules:</h4>
                <ul>
                    <li><strong>Required Columns:</strong> <code>Roll No | Student Name | CAT1 | CAT2 | Class Tests | Assignments | Attendance</code>.</li>
                    <li><strong>Component Limits:</strong> CAT1 (0–30), CAT2 (0–30), Class Tests (0–4), Assignments (0–4), Attendance (0–2).</li>
                    <li><strong>Continuous Internal Evaluation (CIE) Formulas:</strong>
                        <code>CAT Average = (CAT1 + CAT2) / 2</code> &bull; 
                        <code>Internal Total = CAT Average + Class Tests + Assignments + Attendance</code> (Max: 40).
                    </li>
                    <li><strong>Existing Students:</strong> When Roll No belongs to the selected Branch &amp; Section, existing marks are updated without creating duplicate entries. DB student name is preserved.</li>
                    <li><strong>New Students:</strong> If a student from the selected Branch &amp; Section does not yet exist in the system, a new student record is created and marks are inserted.</li>
                    <li><strong>Integrity Protections:</strong> Rows with missing Roll No, marks exceeding maximums, duplicate roll numbers in the sheet, or students belonging to a different branch/section are rejected to protect database integrity.</li>
                    <li><strong>Transaction Safety:</strong> If an unexpected database failure occurs during import, all operations are automatically rolled back.</li>
                </ul>
            </div>

        </div>

    </main>

    <footer class="footer">
        <p>Web Technologies Course-End Project (A8605) &bull; Vardhaman College of Engineering</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
