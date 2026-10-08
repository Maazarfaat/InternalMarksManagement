package com.vce.marks;

import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * MarksServlet handles loading student lists, retrieving existing marks,
 * manual saving/updating marks in bulk, and Excel-based bulk marks import & template generation.
 * Evaluation Scheme: CAT 1 (30), CAT 2 (30), CAT Avg (30), Class Tests (4), Assignments (4), Attendance (2), Internal Total (40).
 */
@MultipartConfig(
    fileSizeThreshold = 524288,
    maxFileSize = 10485760L,
    maxRequestSize = 20971520L
)
public class MarksServlet extends HttpServlet {

    // Maximum allowed marks per component (out of 40)
    public static final double MAX_CAT1 = 30.0;
    public static final double MAX_CAT2 = 30.0;
    public static final double MAX_CAT_AVG = 30.0;
    public static final double MAX_CLASS_TEST = 4.0;
    public static final double MAX_ASSIGNMENT = 4.0;
    public static final double MAX_ATTENDANCE = 2.0;
    public static final double MAX_TOTAL = 40.0;

    // Branches and Sections mapping
    public static final Map<String, List<String>> BRANCH_SECTIONS = new LinkedHashMap<>();
    static {
        BRANCH_SECTIONS.put("CSE", Arrays.asList("A", "B", "C", "D", "E", "F", "G", "H", "I"));
        BRANCH_SECTIONS.put("CSM", Arrays.asList("A", "B", "C"));
        BRANCH_SECTIONS.put("CSD", Arrays.asList("A", "B", "C"));
        BRANCH_SECTIONS.put("ECE", Arrays.asList("A", "B", "C"));
        BRANCH_SECTIONS.put("IT", Arrays.asList("A", "B", "C"));
        BRANCH_SECTIONS.put("EEE", Arrays.asList("A"));
        BRANCH_SECTIONS.put("MECH", Arrays.asList("A"));
        BRANCH_SECTIONS.put("CIVIL", Arrays.asList("A"));
    }

    // Supported 5 academic courses / subjects
    public static final List<String> VALID_SUBJECTS = Arrays.asList(
        "Web Technologies",
        "Data Science",
        "Software Engineering",
        "Computer Networks",
        "Machine Learning"
    );

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

        // Session authentication check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("facultyId") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Session+expired.+Please+log+in+again.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "load";
        }
        action = action.trim();

        if ("save".equalsIgnoreCase(action)) {
            handleSaveMarks(request, response);
        } else if ("download_template".equalsIgnoreCase(action)) {
            handleDownloadTemplate(request, response);
        } else if ("import_excel".equalsIgnoreCase(action)) {
            handleExcelImportOrPreview(request, response, false);
        } else if ("preview_excel".equalsIgnoreCase(action)) {
            handleExcelImportOrPreview(request, response, true);
        } else if ("confirm_import".equalsIgnoreCase(action)) {
            handleConfirmImport(request, response);
        } else {
            handleLoadMarks(request, response);
        }
    }

    /**
     * Loads students and existing marks for the selected branch, section, subject, and assessment.
     */
    private void handleLoadMarks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String branch = request.getParameter("branch");
        if (branch == null || branch.trim().isEmpty()) {
            branch = "IT"; // Default branch
        }
        branch = branch.trim().toUpperCase();
        if (!BRANCH_SECTIONS.containsKey(branch)) {
            branch = "IT";
        }

        String section = request.getParameter("section");
        if (section == null || section.trim().isEmpty()) {
            section = "A"; // Default section
        }
        section = section.trim().toUpperCase();
        List<String> validSections = BRANCH_SECTIONS.get(branch);
        if (!validSections.contains(section)) {
            section = validSections.get(0);
        }

        String subject = request.getParameter("subject");
        if (subject == null || subject.trim().isEmpty() || !VALID_SUBJECTS.contains(subject.trim())) {
            subject = "Web Technologies";
        }
        subject = subject.trim();

        String assessment = request.getParameter("assessment");
        if (assessment == null || assessment.trim().isEmpty()) {
            assessment = "Internal Assessment 1";
        }
        assessment = assessment.trim();

        List<Map<String, Object>> studentList = new ArrayList<>();
        String errorMsg = null;

        String query = "SELECT s.student_id, s.roll_no, s.name, s.section, s.department, s.semester, "
                + "       m.mark_id, m.cat1_marks, m.cat2_marks, m.cat_average, m.class_test_marks, "
                + "       m.assignment_marks, m.attendance_marks, m.total_internal_marks "
                + "FROM students s "
                + "LEFT JOIN marks m ON s.student_id = m.student_id AND m.subject = ? AND m.assessment = ? "
                + "WHERE s.department = ? AND s.section = ? "
                + "ORDER BY s.roll_no ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, subject);
            ps.setString(2, assessment);
            ps.setString(3, branch);
            ps.setString(4, section);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("student_id", rs.getInt("student_id"));
                    map.put("roll_no", rs.getString("roll_no"));
                    map.put("name", rs.getString("name"));
                    map.put("section", rs.getString("section"));
                    map.put("department", rs.getString("department"));
                    map.put("semester", rs.getInt("semester"));

                    // Marks may be null if not yet entered
                    Object markIdObj = rs.getObject("mark_id");
                    if (markIdObj != null) {
                        map.put("has_marks", true);
                        map.put("cat1_marks", rs.getDouble("cat1_marks"));
                        map.put("cat2_marks", rs.getDouble("cat2_marks"));
                        map.put("cat_average", rs.getDouble("cat_average"));
                        map.put("class_test_marks", rs.getDouble("class_test_marks"));
                        map.put("assignment_marks", rs.getDouble("assignment_marks"));
                        map.put("attendance_marks", rs.getDouble("attendance_marks"));
                        map.put("total_internal_marks", rs.getDouble("total_internal_marks"));
                    } else {
                        map.put("has_marks", false);
                        map.put("cat1_marks", 0.0);
                        map.put("cat2_marks", 0.0);
                        map.put("cat_average", 0.0);
                        map.put("class_test_marks", 0.0);
                        map.put("assignment_marks", 0.0);
                        map.put("attendance_marks", 0.0);
                        map.put("total_internal_marks", 0.0);
                    }
                    studentList.add(map);
                }
            }

        } catch (Exception e) {
            System.err.println("Error loading students for " + branch + " section " + section + ": " + e.getMessage());
            errorMsg = "Database error occurred while retrieving student records.";
        }

        request.setAttribute("studentList", studentList);
        request.setAttribute("selectedBranch", branch);
        request.setAttribute("selectedSection", section);
        request.setAttribute("selectedSubject", subject);
        request.setAttribute("selectedAssessment", assessment);
        request.setAttribute("branchSectionsMap", BRANCH_SECTIONS);
        request.setAttribute("validSubjectsList", VALID_SUBJECTS);
        if (errorMsg != null && request.getAttribute("errorMessage") == null) {
            request.setAttribute("errorMessage", errorMsg);
        }

        request.getRequestDispatcher("/faculty.jsp").forward(request, response);
    }

    /**
     * Saves or updates marks in bulk using a database transaction (Manual Entry).
     */
    private void handleSaveMarks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String branch = request.getParameter("branch");
        if (branch == null || branch.trim().isEmpty()) branch = "IT";
        branch = branch.trim().toUpperCase();

        String section = request.getParameter("section");
        String subject = request.getParameter("subject");
        String assessment = request.getParameter("assessment");

        if (section == null || section.trim().isEmpty()) section = "A";
        if (subject == null || subject.trim().isEmpty()) subject = "Web Technologies";
        if (assessment == null || assessment.trim().isEmpty()) assessment = "Internal Assessment 1";

        section = section.trim().toUpperCase();
        subject = subject.trim();
        assessment = assessment.trim();

        String[] studentIds = request.getParameterValues("student_id");
        String[] cat1Arr = request.getParameterValues("cat1_marks");
        String[] cat2Arr = request.getParameterValues("cat2_marks");
        String[] classTestArr = request.getParameterValues("class_test_marks");
        String[] assignmentArr = request.getParameterValues("assignment_marks");
        String[] attendanceArr = request.getParameterValues("attendance_marks");

        if (studentIds == null || studentIds.length == 0) {
            request.setAttribute("errorMessage", "No student records submitted for saving.");
            handleLoadMarks(request, response);
            return;
        }

        // Validate lengths
        int n = studentIds.length;
        if (cat1Arr == null || cat1Arr.length != n ||
            cat2Arr == null || cat2Arr.length != n ||
            classTestArr == null || classTestArr.length != n ||
            assignmentArr == null || assignmentArr.length != n ||
            attendanceArr == null || attendanceArr.length != n) {
            request.setAttribute("errorMessage", "Form submission error: parameter count mismatch.");
            handleLoadMarks(request, response);
            return;
        }

        // Validate marks range before starting transaction
        double[][] parsedMarks = new double[n][7];
        int[] parsedStudentIds = new int[n];

        for (int i = 0; i < n; i++) {
            try {
                parsedStudentIds[i] = Integer.parseInt(studentIds[i].trim());

                double cat1 = parseDoubleField(cat1Arr[i]);
                double cat2 = parseDoubleField(cat2Arr[i]);
                double classTest = parseDoubleField(classTestArr[i]);
                double assign = parseDoubleField(assignmentArr[i]);
                double att = parseDoubleField(attendanceArr[i]);

                if (cat1 < 0 || cat1 > MAX_CAT1) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": CAT 1 marks must be between 0 and " + MAX_CAT1);
                    handleLoadMarks(request, response);
                    return;
                }
                if (cat2 < 0 || cat2 > MAX_CAT2) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": CAT 2 marks must be between 0 and " + MAX_CAT2);
                    handleLoadMarks(request, response);
                    return;
                }
                if (classTest < 0 || classTest > MAX_CLASS_TEST) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": Class Test marks must be between 0 and " + MAX_CLASS_TEST);
                    handleLoadMarks(request, response);
                    return;
                }
                if (assign < 0 || assign > MAX_ASSIGNMENT) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": Assignment marks must be between 0 and " + MAX_ASSIGNMENT);
                    handleLoadMarks(request, response);
                    return;
                }
                if (att < 0 || att > MAX_ATTENDANCE) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": Attendance marks must be between 0 and " + MAX_ATTENDANCE);
                    handleLoadMarks(request, response);
                    return;
                }

                double catAvg = (cat1 + cat2) / 2.0;
                double total = catAvg + classTest + assign + att;
                if (total > MAX_TOTAL) {
                    request.setAttribute("errorMessage", "Row " + (i + 1) + ": Internal Total exceeds maximum of " + MAX_TOTAL);
                    handleLoadMarks(request, response);
                    return;
                }

                parsedMarks[i][0] = cat1;
                parsedMarks[i][1] = cat2;
                parsedMarks[i][2] = catAvg;
                parsedMarks[i][3] = classTest;
                parsedMarks[i][4] = assign;
                parsedMarks[i][5] = att;
                parsedMarks[i][6] = total;

            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Row " + (i + 1) + ": Invalid numeric value entered.");
                handleLoadMarks(request, response);
                return;
            }
        }

        // Database Transaction Execution
        String checkSql = "SELECT mark_id FROM marks WHERE student_id = ? AND subject = ? AND assessment = ?";
        String insertSql = "INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks) "
                         + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE marks SET cat1_marks = ?, cat2_marks = ?, cat_average = ?, class_test_marks = ?, assignment_marks = ?, attendance_marks = ?, total_internal_marks = ?, updated_at = CURRENT_TIMESTAMP "
                         + "WHERE mark_id = ?";

        Connection conn = null;
        int insertCount = 0;
        int updateCount = 0;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // BEGIN TRANSACTION

            try (PreparedStatement checkPs = conn.prepareStatement(checkSql);
                 PreparedStatement insertPs = conn.prepareStatement(insertSql);
                 PreparedStatement updatePs = conn.prepareStatement(updateSql)) {

                for (int i = 0; i < n; i++) {
                    int sid = parsedStudentIds[i];
                    double cat1 = parsedMarks[i][0];
                    double cat2 = parsedMarks[i][1];
                    double catAvg = parsedMarks[i][2];
                    double classTest = parsedMarks[i][3];
                    double assign = parsedMarks[i][4];
                    double att = parsedMarks[i][5];
                    double total = parsedMarks[i][6];

                    checkPs.setInt(1, sid);
                    checkPs.setString(2, subject);
                    checkPs.setString(3, assessment);

                    int existingMarkId = -1;
                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (rs.next()) {
                            existingMarkId = rs.getInt("mark_id");
                        }
                    }

                    if (existingMarkId != -1) {
                        // UPDATE
                        updatePs.setDouble(1, cat1);
                        updatePs.setDouble(2, cat2);
                        updatePs.setDouble(3, catAvg);
                        updatePs.setDouble(4, classTest);
                        updatePs.setDouble(5, assign);
                        updatePs.setDouble(6, att);
                        updatePs.setDouble(7, total);
                        updatePs.setInt(8, existingMarkId);
                        updatePs.executeUpdate();
                        updateCount++;
                    } else {
                        // INSERT
                        insertPs.setInt(1, sid);
                        insertPs.setString(2, subject);
                        insertPs.setString(3, assessment);
                        insertPs.setDouble(4, cat1);
                        insertPs.setDouble(5, cat2);
                        insertPs.setDouble(6, catAvg);
                        insertPs.setDouble(7, classTest);
                        insertPs.setDouble(8, assign);
                        insertPs.setDouble(9, att);
                        insertPs.setDouble(10, total);
                        insertPs.executeUpdate();
                        insertCount++;
                    }
                }

                conn.commit(); // COMMIT TRANSACTION
                request.setAttribute("successMessage", "Marks saved successfully for Section " + section
                        + " (" + insertCount + " inserted, " + updateCount + " updated).");

            } catch (SQLException e) {
                if (conn != null) {
                    try {
                        conn.rollback(); // ROLLBACK ON ERROR
                    } catch (SQLException ex) {
                        System.err.println("Rollback failed: " + ex.getMessage());
                    }
                }
                System.err.println("Database transaction failed: " + e.getMessage());
                request.setAttribute("errorMessage", "Database transaction failed. All changes rolled back.");
            }

        } catch (Exception e) {
            System.err.println("Database connection failed: " + e.getMessage());
            request.setAttribute("errorMessage", "Database connection failure. Could not save marks.");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }

        // Reload updated students and marks for display
        handleLoadMarks(request, response);
    }

    /**
     * Generates and downloads an Excel .xlsx template formatted to project requirements.
     */
    private void handleDownloadTemplate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String branch = request.getParameter("branch");
        if (branch == null || branch.trim().isEmpty() || !BRANCH_SECTIONS.containsKey(branch.trim().toUpperCase())) {
            branch = "IT";
        }
        branch = branch.trim().toUpperCase();

        String section = request.getParameter("section");
        if (section == null || section.trim().isEmpty()) {
            section = "A";
        }
        section = section.trim().toUpperCase();

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Marks_" + branch + "_" + section);

            // Styling for header row
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);

            // Data styling
            CellStyle textStyle = workbook.createCellStyle();
            textStyle.setBorderBottom(BorderStyle.THIN);
            textStyle.setBorderTop(BorderStyle.THIN);
            textStyle.setBorderLeft(BorderStyle.THIN);
            textStyle.setBorderRight(BorderStyle.THIN);

            CellStyle numberStyle = workbook.createCellStyle();
            numberStyle.setDataFormat(workbook.createDataFormat().getFormat("0.0#"));
            numberStyle.setAlignment(HorizontalAlignment.RIGHT);
            numberStyle.setBorderBottom(BorderStyle.THIN);
            numberStyle.setBorderTop(BorderStyle.THIN);
            numberStyle.setBorderLeft(BorderStyle.THIN);
            numberStyle.setBorderRight(BorderStyle.THIN);

            String[] headers = {
                "Roll No",
                "Student Name",
                "CAT1",
                "CAT2",
                "Class Tests",
                "Assignments",
                "Attendance"
            };

            Row headerRow = sheet.createRow(0);
            headerRow.setHeightInPoints(26);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Fetch existing students in this branch and section to pre-populate template
            List<String[]> students = new ArrayList<>();
            String sql = "SELECT roll_no, name FROM students WHERE department = ? AND section = ? ORDER BY roll_no ASC";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, branch);
                ps.setString(2, section);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        students.add(new String[]{rs.getString("roll_no"), rs.getString("name")});
                    }
                }
            } catch (Exception e) {
                System.err.println("Error fetching students for template download: " + e.getMessage());
            }

            int rowIdx = 1;
            if (!students.isEmpty()) {
                for (String[] st : students) {
                    Row row = sheet.createRow(rowIdx++);
                    Cell c0 = row.createCell(0); c0.setCellValue(st[0]); c0.setCellStyle(textStyle);
                    Cell c1 = row.createCell(1); c1.setCellValue(st[1]); c1.setCellStyle(textStyle);
                    for (int c = 2; c < 7; c++) {
                        Cell mc = row.createCell(c);
                        mc.setCellStyle(numberStyle);
                    }
                }
            } else {
                // If branch/section has no students yet, provide realistic sample rows
                String[][] demoRows = {
                    {"24881A0501", "Demo Student 1", "25.0", "26.0", "3.5", "4.0", "2.0"},
                    {"24881A0502", "Demo Student 2", "28.0", "29.0", "4.0", "3.5", "2.0"},
                    {"24881A0503", "Demo Student 3", "22.5", "24.0", "3.0", "3.0", "1.5"}
                };
                for (String[] demo : demoRows) {
                    Row row = sheet.createRow(rowIdx++);
                    Cell c0 = row.createCell(0); c0.setCellValue(demo[0]); c0.setCellStyle(textStyle);
                    Cell c1 = row.createCell(1); c1.setCellValue(demo[1]); c1.setCellStyle(textStyle);
                    for (int c = 2; c < 7; c++) {
                        Cell mc = row.createCell(c);
                        mc.setCellValue(Double.parseDouble(demo[c]));
                        mc.setCellStyle(numberStyle);
                    }
                }
            }

            // Adjust column widths
            sheet.setColumnWidth(0, 18 * 256);
            sheet.setColumnWidth(1, 32 * 256);
            sheet.setColumnWidth(2, 14 * 256);
            sheet.setColumnWidth(3, 14 * 256);
            sheet.setColumnWidth(4, 15 * 256);
            sheet.setColumnWidth(5, 15 * 256);
            sheet.setColumnWidth(6, 14 * 256);

            String filename = "Internal_Marks_Template_" + branch + "_" + section + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            workbook.write(response.getOutputStream());
            response.getOutputStream().flush();

        } catch (Exception e) {
            System.err.println("Error generating Excel template: " + e.getMessage());
            request.setAttribute("errorMessage", "Failed to generate Excel template: " + e.getMessage());
            handleLoadMarks(request, response);
        }
    }

    /**
     * Handles parsing, validation, preview, and transactional database import of .xlsx file.
     */
    private void handleExcelImportOrPreview(HttpServletRequest request, HttpServletResponse response, boolean isPreviewOnly)
            throws ServletException, IOException {

        request.setAttribute("activeTab", "excel");

        String branch = request.getParameter("branch");
        if (branch == null || branch.trim().isEmpty() || !BRANCH_SECTIONS.containsKey(branch.trim().toUpperCase())) {
            branch = "IT";
        }
        branch = branch.trim().toUpperCase();

        String section = request.getParameter("section");
        if (section == null || section.trim().isEmpty()) {
            section = "A";
        }
        section = section.trim().toUpperCase();
        List<String> validSections = BRANCH_SECTIONS.get(branch);
        if (!validSections.contains(section)) {
            section = validSections.get(0);
        }

        String subject = request.getParameter("subject");
        if (subject == null || subject.trim().isEmpty() || !VALID_SUBJECTS.contains(subject.trim())) {
            subject = "Web Technologies";
        }
        subject = subject.trim();

        String assessment = "Internal Assessment 1";

        Part filePart = null;
        try {
            filePart = request.getPart("excelFile");
        } catch (Exception e) {
            System.err.println("Error retrieving multipart file: " + e.getMessage());
        }

        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("errorMessage", "Please select a valid .xlsx Excel file to upload.");
            handleLoadMarks(request, response);
            return;
        }

        String submittedFileName = filePart.getSubmittedFileName();
        if (submittedFileName == null || !submittedFileName.toLowerCase().endsWith(".xlsx")) {
            request.setAttribute("errorMessage", "Unsupported file type. Only Excel workbooks with .xlsx extension are accepted.");
            handleLoadMarks(request, response);
            return;
        }

        List<ExcelRowData> parsedRows = new ArrayList<>();
        List<Map<String, Object>> rowErrors = new ArrayList<>();
        Set<String> seenRollNosInSheet = new HashSet<>();
        DataFormatter formatter = new DataFormatter();

        try (InputStream is = filePart.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {

            if (workbook.getNumberOfSheets() == 0) {
                request.setAttribute("errorMessage", "The uploaded Excel workbook contains no worksheets.");
                handleLoadMarks(request, response);
                return;
            }

            Sheet sheet = workbook.getSheetAt(0);
            if (sheet == null || sheet.getPhysicalNumberOfRows() == 0) {
                request.setAttribute("errorMessage", "The uploaded Excel worksheet is empty.");
                handleLoadMarks(request, response);
                return;
            }

            // Find header row
            int headerRowIdx = -1;
            int rollNoCol = -1;
            int nameCol = -1;
            int cat1Col = -1;
            int cat2Col = -1;
            int classTestCol = -1;
            int assignCol = -1;
            int attCol = -1;

            for (int r = 0; r <= Math.min(sheet.getLastRowNum(), 10); r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;

                for (int c = 0; c < row.getLastCellNum(); c++) {
                    Cell cell = row.getCell(c);
                    if (cell == null) continue;
                    String val = formatter.formatCellValue(cell).toLowerCase().replaceAll("[\\s_]+", "");
                    if (val.contains("roll")) rollNoCol = c;
                    else if (val.contains("name") || val.contains("student")) nameCol = c;
                    else if (val.contains("cat1")) cat1Col = c;
                    else if (val.contains("cat2")) cat2Col = c;
                    else if (val.contains("class") || val.contains("test")) classTestCol = c;
                    else if (val.contains("assign")) assignCol = c;
                    else if (val.contains("attend")) attCol = c;
                }

                if (rollNoCol != -1 && cat1Col != -1 && cat2Col != -1 &&
                    classTestCol != -1 && assignCol != -1 && attCol != -1) {
                    headerRowIdx = r;
                    break;
                }
            }

            if (headerRowIdx == -1) {
                List<String> missingCols = new ArrayList<>();
                if (rollNoCol == -1) missingCols.add("Roll No");
                if (nameCol == -1) missingCols.add("Student Name");
                if (cat1Col == -1) missingCols.add("CAT1");
                if (cat2Col == -1) missingCols.add("CAT2");
                if (classTestCol == -1) missingCols.add("Class Tests");
                if (assignCol == -1) missingCols.add("Assignments");
                if (attCol == -1) missingCols.add("Attendance");

                request.setAttribute("errorMessage", "Invalid Excel format. Missing required column(s): "
                        + String.join(", ", missingCols)
                        + ". Expected: Roll No | Student Name | CAT1 | CAT2 | Class Tests | Assignments | Attendance");
                handleLoadMarks(request, response);
                return;
            }

            // Connect to DB to validate students and departments
            try (Connection conn = DBConnection.getConnection()) {
                String findStudentSql = "SELECT student_id, name, department, section FROM students WHERE UPPER(roll_no) = UPPER(?)";

                try (PreparedStatement findPs = conn.prepareStatement(findStudentSql)) {

                    for (int r = headerRowIdx + 1; r <= sheet.getLastRowNum(); r++) {
                        Row row = sheet.getRow(r);
                        if (row == null) continue;

                        String rawRoll = rollNoCol != -1 ? formatter.formatCellValue(row.getCell(rollNoCol)) : "";
                        String rawName = nameCol != -1 ? formatter.formatCellValue(row.getCell(nameCol)) : "";
                        String rawCat1 = cat1Col != -1 ? formatter.formatCellValue(row.getCell(cat1Col)) : "";
                        String rawCat2 = cat2Col != -1 ? formatter.formatCellValue(row.getCell(cat2Col)) : "";
                        String rawCt = classTestCol != -1 ? formatter.formatCellValue(row.getCell(classTestCol)) : "";
                        String rawAssign = assignCol != -1 ? formatter.formatCellValue(row.getCell(assignCol)) : "";
                        String rawAtt = attCol != -1 ? formatter.formatCellValue(row.getCell(attCol)) : "";

                        // Skip completely empty row
                        if (rawRoll.trim().isEmpty() && rawName.trim().isEmpty() &&
                            rawCat1.trim().isEmpty() && rawCat2.trim().isEmpty() &&
                            rawCt.trim().isEmpty() && rawAssign.trim().isEmpty() && rawAtt.trim().isEmpty()) {
                            continue;
                        }

                        ExcelRowData rowData = new ExcelRowData();
                        rowData.setRowNum(r + 1); // 1-based Excel row number
                        rowData.setRollNo(rawRoll.trim().toUpperCase());
                        rowData.setName(rawName.trim());

                        // 1. Roll No Mandatory Check
                        if (rowData.getRollNo().isEmpty()) {
                            rowData.addError("Roll No is mandatory and cannot be empty.");
                        } else {
                            // 2. Duplicate in sheet check
                            if (seenRollNosInSheet.contains(rowData.getRollNo())) {
                                rowData.addError("Duplicate Roll No '" + rowData.getRollNo() + "' found in this Excel sheet.");
                            } else {
                                seenRollNosInSheet.add(rowData.getRollNo());
                            }
                        }

                        // 3. Marks Parsing & Range Validations
                        Double cat1 = parseCellNumeric(row.getCell(cat1Col), rawCat1);
                        if (cat1 == null) {
                            rowData.addError("Invalid CAT 1 mark value ('" + rawCat1 + "'). Must be a number between 0 and " + MAX_CAT1);
                        } else if (cat1 < 0.0 || cat1 > MAX_CAT1) {
                            rowData.addError("CAT 1 marks (" + cat1 + ") must be between 0 and " + MAX_CAT1);
                        } else {
                            rowData.setCat1(cat1);
                        }

                        Double cat2 = parseCellNumeric(row.getCell(cat2Col), rawCat2);
                        if (cat2 == null) {
                            rowData.addError("Invalid CAT 2 mark value ('" + rawCat2 + "'). Must be a number between 0 and " + MAX_CAT2);
                        } else if (cat2 < 0.0 || cat2 > MAX_CAT2) {
                            rowData.addError("CAT 2 marks (" + cat2 + ") must be between 0 and " + MAX_CAT2);
                        } else {
                            rowData.setCat2(cat2);
                        }

                        Double ct = parseCellNumeric(row.getCell(classTestCol), rawCt);
                        if (ct == null) {
                            rowData.addError("Invalid Class Tests mark value ('" + rawCt + "'). Must be a number between 0 and " + MAX_CLASS_TEST);
                        } else if (ct < 0.0 || ct > MAX_CLASS_TEST) {
                            rowData.addError("Class Tests marks (" + ct + ") must be between 0 and " + MAX_CLASS_TEST);
                        } else {
                            rowData.setClassTest(ct);
                        }

                        Double assign = parseCellNumeric(row.getCell(assignCol), rawAssign);
                        if (assign == null) {
                            rowData.addError("Invalid Assignments mark value ('" + rawAssign + "'). Must be a number between 0 and " + MAX_ASSIGNMENT);
                        } else if (assign < 0.0 || assign > MAX_ASSIGNMENT) {
                            rowData.addError("Assignments marks (" + assign + ") must be between 0 and " + MAX_ASSIGNMENT);
                        } else {
                            rowData.setAssignment(assign);
                        }

                        Double att = parseCellNumeric(row.getCell(attCol), rawAtt);
                        if (att == null) {
                            rowData.addError("Invalid Attendance mark value ('" + rawAtt + "'). Must be a number between 0 and " + MAX_ATTENDANCE);
                        } else if (att < 0.0 || att > MAX_ATTENDANCE) {
                            rowData.addError("Attendance marks (" + att + ") must be between 0 and " + MAX_ATTENDANCE);
                        } else {
                            rowData.setAttendance(att);
                        }

                        // Calculate CAT Avg and Total
                        if (rowData.getErrors().isEmpty() || 
                            (cat1 != null && cat2 != null && ct != null && assign != null && att != null)) {
                            double c1Val = cat1 != null ? cat1 : 0.0;
                            double c2Val = cat2 != null ? cat2 : 0.0;
                            double ctVal = ct != null ? ct : 0.0;
                            double aVal = assign != null ? assign : 0.0;
                            double attVal = att != null ? att : 0.0;

                            double catAvg = (c1Val + c2Val) / 2.0;
                            double total = catAvg + ctVal + aVal + attVal;
                            rowData.setCatAverage(Math.round(catAvg * 100.0) / 100.0);
                            rowData.setTotal(Math.round(total * 100.0) / 100.0);

                            if (total > MAX_TOTAL) {
                                rowData.addError("Internal Total (" + rowData.getTotal() + ") exceeds maximum limit of " + MAX_TOTAL);
                            }
                        }

                        // 4. Database Student Verification
                        if (!rowData.getRollNo().isEmpty()) {
                            findPs.setString(1, rowData.getRollNo());
                            try (ResultSet rs = findPs.executeQuery()) {
                                if (rs.next()) {
                                    // Existing student
                                    String dbDept = rs.getString("department");
                                    String dbSec = rs.getString("section");
                                    String dbName = rs.getString("name");

                                    // Verify branch + section matches
                                    if (!dbDept.equalsIgnoreCase(branch) || !dbSec.equalsIgnoreCase(section)) {
                                        rowData.addError("Student belonging to another branch/section: Roll No "
                                                + rowData.getRollNo() + " belongs to " + dbDept + " Section " + dbSec
                                                + ", conflicting with selected " + branch + " Section " + section + ".");
                                    } else {
                                        rowData.setStudentId(rs.getInt("student_id"));
                                        rowData.setNewStudent(false);
                                        // Rule: Use existing DB name when student already exists
                                        rowData.setName(dbName);
                                    }
                                } else {
                                    // New student to be created
                                    rowData.setNewStudent(true);
                                    rowData.setStudentId(-1);
                                    if (rowData.getName().isEmpty()) {
                                        rowData.addError("Student Name is mandatory for creating a new student record (Roll No: "
                                                + rowData.getRollNo() + ").");
                                    }
                                }
                            }
                        }

                        parsedRows.add(rowData);
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("Error reading Excel file: " + e.getMessage());
            request.setAttribute("errorMessage", "Error parsing Excel workbook: " + e.getMessage());
            handleLoadMarks(request, response);
            return;
        }

        if (parsedRows.isEmpty()) {
            request.setAttribute("errorMessage", "The uploaded Excel file contains no data rows.");
            handleLoadMarks(request, response);
            return;
        }

        // Separate valid and failed rows
        List<ExcelRowData> validRows = new ArrayList<>();
        List<ExcelRowData> failedRows = new ArrayList<>();

        for (ExcelRowData r : parsedRows) {
            if (r.isValid()) {
                validRows.add(r);
            } else {
                failedRows.add(r);
                Map<String, Object> errMap = new HashMap<>();
                errMap.put("rowNum", r.getRowNum());
                errMap.put("rollNo", r.getRollNo().isEmpty() ? "(Empty)" : r.getRollNo());
                errMap.put("name", r.getName().isEmpty() ? "(Empty)" : r.getName());
                errMap.put("errors", String.join("; ", r.getErrors()));
                rowErrors.add(errMap);
            }
        }

        Map<String, Object> summary = new HashMap<>();
        summary.put("totalRows", parsedRows.size());
        summary.put("successRows", validRows.size());
        summary.put("failedRows", failedRows.size());

        request.setAttribute("importSummary", summary);
        request.setAttribute("rowErrors", rowErrors);
        request.setAttribute("previewRows", parsedRows);

        if (isPreviewOnly) {
            // Preview / Validate Mode - No DB changes made
            request.setAttribute("isPreview", true);
            // Save valid rows in session so user can confirm and import without re-uploading
            HttpSession session = request.getSession(true);
            session.setAttribute("pendingValidRows", validRows);
            session.setAttribute("pendingBranch", branch);
            session.setAttribute("pendingSection", section);
            session.setAttribute("pendingSubject", subject);
            session.setAttribute("pendingAssessment", assessment);

            if (failedRows.isEmpty()) {
                request.setAttribute("successMessage", "Validation Passed: All " + validRows.size()
                        + " rows are valid and ready to import into MySQL.");
            } else {
                request.setAttribute("errorMessage", "Validation Preview: " + validRows.size()
                        + " valid rows, " + failedRows.size() + " invalid rows detected. Review details below.");
            }

        } else {
            // Import Mode - Execute Transaction
            if (validRows.isEmpty()) {
                request.setAttribute("errorMessage", "Import rejected: No valid rows found in the Excel file. Please fix the validation errors below.");
            } else {
                int importedCount = executeImportTransaction(validRows, branch, section, subject, assessment, request);
                summary.put("successRows", importedCount);
                if (importedCount > 0) {
                    if (failedRows.isEmpty()) {
                        request.setAttribute("successMessage", "Excel Import Successful! All " + importedCount
                                + " student marks imported/updated in MySQL for " + branch + " Section " + section + ".");
                    } else {
                        request.setAttribute("successMessage", "Excel Import Completed: " + importedCount
                                + " student records updated in MySQL. " + failedRows.size() + " invalid row(s) were rejected.");
                    }
                }
            }
        }

        handleLoadMarks(request, response);
    }

    /**
     * Executes transactional import of previously validated pending rows from session.
     */
    private void handleConfirmImport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activeTab", "excel");
        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("errorMessage", "Session expired. Please try again.");
            handleLoadMarks(request, response);
            return;
        }

        @SuppressWarnings("unchecked")
        List<ExcelRowData> validRows = (List<ExcelRowData>) session.getAttribute("pendingValidRows");
        String branch = (String) session.getAttribute("pendingBranch");
        String section = (String) session.getAttribute("pendingSection");
        String subject = (String) session.getAttribute("pendingSubject");
        String assessment = (String) session.getAttribute("pendingAssessment");

        if (validRows == null || validRows.isEmpty()) {
            request.setAttribute("errorMessage", "No validated records pending import. Please choose an Excel file to validate first.");
            handleLoadMarks(request, response);
            return;
        }

        int importedCount = executeImportTransaction(validRows, branch, section, subject, assessment, request);

        // Clear session pending data
        session.removeAttribute("pendingValidRows");
        session.removeAttribute("pendingBranch");
        session.removeAttribute("pendingSection");
        session.removeAttribute("pendingSubject");
        session.removeAttribute("pendingAssessment");

        if (importedCount > 0) {
            Map<String, Object> summary = new HashMap<>();
            summary.put("totalRows", validRows.size());
            summary.put("successRows", importedCount);
            summary.put("failedRows", 0);
            request.setAttribute("importSummary", summary);
            request.setAttribute("successMessage", "Excel Import Confirmed! " + importedCount
                    + " student marks saved to MySQL for " + branch + " Section " + section + " (" + subject + ").");
        }

        handleLoadMarks(request, response);
    }

    /**
     * Executes atomic database transaction for inserting/updating valid students and marks.
     */
    private int executeImportTransaction(List<ExcelRowData> validRows, String branch, String section,
                                         String subject, String assessment, HttpServletRequest request) {

        String insertStudentSql = "INSERT INTO students (roll_no, name, section, department, semester) VALUES (?, ?, ?, ?, 5)";
        String checkMarkSql = "SELECT mark_id FROM marks WHERE student_id = ? AND subject = ? AND assessment = ?";
        String updateMarkSql = "UPDATE marks SET cat1_marks = ?, cat2_marks = ?, cat_average = ?, "
                             + "       class_test_marks = ?, assignment_marks = ?, attendance_marks = ?, "
                             + "       total_internal_marks = ?, updated_at = CURRENT_TIMESTAMP WHERE mark_id = ?";
        String insertMarkSql = "INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, "
                             + "       cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        int importedCount = 0;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // BEGIN TRANSACTION

            try (PreparedStatement insertStudentPs = conn.prepareStatement(insertStudentSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement checkMarkPs = conn.prepareStatement(checkMarkSql);
                 PreparedStatement updateMarkPs = conn.prepareStatement(updateMarkSql);
                 PreparedStatement insertMarkPs = conn.prepareStatement(insertMarkSql)) {

                for (ExcelRowData row : validRows) {
                    int sid = row.getStudentId();

                    // 1. If student does not exist, insert student record
                    if (row.isNewStudent() || sid <= 0) {
                        insertStudentPs.setString(1, row.getRollNo());
                        insertStudentPs.setString(2, row.getName());
                        insertStudentPs.setString(3, section);
                        insertStudentPs.setString(4, branch);
                        insertStudentPs.executeUpdate();

                        try (ResultSet rsKeys = insertStudentPs.getGeneratedKeys()) {
                            if (rsKeys.next()) {
                                sid = rsKeys.getInt(1);
                                row.setStudentId(sid);
                            } else {
                                throw new SQLException("Failed to retrieve generated student_id for " + row.getRollNo());
                            }
                        }
                    }

                    // 2. Check if marks already exist
                    checkMarkPs.setInt(1, sid);
                    checkMarkPs.setString(2, subject);
                    checkMarkPs.setString(3, assessment);

                    int existingMarkId = -1;
                    try (ResultSet rs = checkMarkPs.executeQuery()) {
                        if (rs.next()) {
                            existingMarkId = rs.getInt("mark_id");
                        }
                    }

                    // 3. Update or Insert marks
                    if (existingMarkId != -1) {
                        updateMarkPs.setDouble(1, row.getCat1());
                        updateMarkPs.setDouble(2, row.getCat2());
                        updateMarkPs.setDouble(3, row.getCatAverage());
                        updateMarkPs.setDouble(4, row.getClassTest());
                        updateMarkPs.setDouble(5, row.getAssignment());
                        updateMarkPs.setDouble(6, row.getAttendance());
                        updateMarkPs.setDouble(7, row.getTotal());
                        updateMarkPs.setInt(8, existingMarkId);
                        updateMarkPs.executeUpdate();
                    } else {
                        insertMarkPs.setInt(1, sid);
                        insertMarkPs.setString(2, subject);
                        insertMarkPs.setString(3, assessment);
                        insertMarkPs.setDouble(4, row.getCat1());
                        insertMarkPs.setDouble(5, row.getCat2());
                        insertMarkPs.setDouble(6, row.getCatAverage());
                        insertMarkPs.setDouble(7, row.getClassTest());
                        insertMarkPs.setDouble(8, row.getAssignment());
                        insertMarkPs.setDouble(9, row.getAttendance());
                        insertMarkPs.setDouble(10, row.getTotal());
                        insertMarkPs.executeUpdate();
                    }

                    importedCount++;
                }

                conn.commit(); // COMMIT TRANSACTION

            } catch (SQLException e) {
                if (conn != null) {
                    try {
                        conn.rollback(); // ROLLBACK TRANSACTION ON FAILURE
                    } catch (SQLException ex) {
                        System.err.println("Rollback failed: " + ex.getMessage());
                    }
                }
                System.err.println("Transaction failed during Excel import: " + e.getMessage());
                request.setAttribute("errorMessage", "Database transaction failed during import. All changes rolled back: " + e.getMessage());
                return 0;
            }

        } catch (Exception e) {
            System.err.println("Connection error during Excel import: " + e.getMessage());
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            return 0;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }

        return importedCount;
    }

    /**
     * Safely parses numeric value from Excel cell or formatted string.
     */
    private static Double parseCellNumeric(Cell cell, String rawStr) {
        if (cell != null && cell.getCellType() == CellType.NUMERIC) {
            return cell.getNumericCellValue();
        }
        if (rawStr == null || rawStr.trim().isEmpty()) {
            return 0.0;
        }
        try {
            return Double.parseDouble(rawStr.trim());
        } catch (NumberFormatException e) {
            return null; // invalid numeric representation
        }
    }

    /**
     * Helper method to parse a decimal mark input, defaulting empty or whitespace strings to 0.0.
     */
    private static double parseDoubleField(String val) {
        if (val == null || val.trim().isEmpty()) {
            return 0.0;
        }
        return Double.parseDouble(val.trim());
    }

    /**
     * Model representing a parsed Excel row with validation metadata.
     */
    public static class ExcelRowData implements Serializable {
        private static final long serialVersionUID = 1L;

        private int rowNum;
        private String rollNo = "";
        private String name = "";
        private double cat1 = 0.0;
        private double cat2 = 0.0;
        private double catAverage = 0.0;
        private double classTest = 0.0;
        private double assignment = 0.0;
        private double attendance = 0.0;
        private double total = 0.0;
        private int studentId = -1;
        private boolean isNewStudent = false;
        private List<String> errors = new ArrayList<>();

        public int getRowNum() { return rowNum; }
        public void setRowNum(int rowNum) { this.rowNum = rowNum; }

        public String getRollNo() { return rollNo; }
        public void setRollNo(String rollNo) { this.rollNo = rollNo; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public double getCat1() { return cat1; }
        public void setCat1(double cat1) { this.cat1 = cat1; }

        public double getCat2() { return cat2; }
        public void setCat2(double cat2) { this.cat2 = cat2; }

        public double getCatAverage() { return catAverage; }
        public void setCatAverage(double catAverage) { this.catAverage = catAverage; }

        public double getClassTest() { return classTest; }
        public void setClassTest(double classTest) { this.classTest = classTest; }

        public double getAssignment() { return assignment; }
        public void setAssignment(double assignment) { this.assignment = assignment; }

        public double getAttendance() { return attendance; }
        public void setAttendance(double attendance) { this.attendance = attendance; }

        public double getTotal() { return total; }
        public void setTotal(double total) { this.total = total; }

        public int getStudentId() { return studentId; }
        public void setStudentId(int studentId) { this.studentId = studentId; }

        public boolean isNewStudent() { return isNewStudent; }
        public void setNewStudent(boolean newStudent) { isNewStudent = newStudent; }

        public List<String> getErrors() { return errors; }
        public void addError(String err) { this.errors.add(err); }
        public boolean isValid() { return errors.isEmpty(); }
    }
}
