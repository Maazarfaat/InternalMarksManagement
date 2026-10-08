# INTERNAL MARKS MANAGEMENT SYSTEM
**Academic Web Technologies Course-End Project (A8605)**  
*Department of Information Technology, Vardhaman College of Engineering*

---

## 1. Project Overview & Team Details
- **Course**: Web Technologies Laboratory (A8605)
- **Degree / Branch**: B.Tech Information Technology, Year III &bull; Semester I (Semester 5)
- **Curriculum / Regulation**: VCE-R22 Autonomous
- **Team ID**: `24WT-45`
- **Team Members**:
  1. **Mohammed Maaz Arfaat** &bull; `24881A1245` &bull; Section A *(Team Member 1)*
  2. **Nadikuda Sathish** &bull; `24881A12B0` &bull; Section B *(Team Member 2)*
  3. **Saddi Amulya Reddy** &bull; `24881A12H3` &bull; Section C *(Team Member 3)*
- **Outcome & SDG Mapping**:
  - **Program Outcomes (POs)**: PO1, PO2, PO3, PO5, PO8, PO10
  - **Program Specific Outcomes (PSOs)**: PSO1, PSO2
  - **Sustainable Development Goal**: **SDG 4 (Quality Education)**
  - **Academic Justification**: Supports transparent, accountable, and systematic management of student internal assessment records.

---

## 2. Continuous Internal Evaluation (CIE) Scheme
Aligined strictly with the VCE Autonomous R22 academic evaluation pattern:

$$\text{CAT Average} = \frac{\text{CAT 1 (30)} + \text{CAT 2 (30)}}{2} \quad (\text{Max: 30})$$

$$\text{Internal Total (Max: 40)} = \text{CAT Average (30)} + \text{Class Tests (4)} + \text{Assignments (4)} + \text{Attendance (2)}$$

### Component Breakdown
| Assessment Component | Maximum Marks | Description |
| :--- | :---: | :--- |
| **Continuous Assessment Test 1 (CAT 1)** | 30.0 | Mid-semester written test 1 |
| **Continuous Assessment Test 2 (CAT 2)** | 30.0 | Mid-semester written test 2 |
| **CAT Average** | 30.0 | Arithmetic mean of CAT 1 and CAT 2 |
| **Class Tests** | 4.0 | Continuous class quizzes / short assessments |
| **Assignments** | 4.0 | Evaluated technical assignments |
| **Attendance** | 2.0 | Regularity and laboratory attendance metric |
| **TOTAL INTERNAL MARKS** | **40.0** | Official university continuous assessment score |

### Academic Performance Levels
- **Distinction**: $\ge 32.0$ marks (Green badge)
- **First Class**: $\ge 24.0$ and $< 32.0$ marks (Blue badge)
- **Pass**: $\ge 16.0$ and $< 24.0$ marks (Yellow badge)
- **Remedial**: $< 16.0$ marks (Red badge)
- **Pending**: Unentered / zero marks (Gray badge)

---

## 3. Technology Stack
- **Frontend**: HTML5, Vanilla CSS3 (Custom Design System, Responsive, Print Layouts), Vanilla JavaScript ES6+
- **Backend**: Java 17+, Java Servlet 4.0 (`javax.servlet.*`), JavaServer Pages (JSP 2.3)
- **Session Management**: `HttpSession` with full access protection and logout invalidation
- **Database**: MySQL 8.0 with InnoDB Engine, UTF-8 Encoding
- **Persistence**: Java Database Connectivity (JDBC) using `PreparedStatement` and atomic `Connection` Transactions
- **Application Server**: Apache Tomcat 9.0 (Port 8081)
- **Build & Dependency Tool**: Apache Maven 3.9+ (`war` packaging)

---

## 4. Key Features
1. **Faculty Authentication**: Simple, secure login using `HttpSession` with session timeout (30 min) and 1-click demo login capability.
2. **Automated Roster Population**: Students are dynamically loaded from MySQL by Section (A: 70, B: 68, C: 67) — zero hardcoded records. Lateral entry roll numbers (`25885A12xx`) are preserved.
3. **Dynamic JavaScript Calculation**: Instant computation of CAT Average, Internal Total, and live academic performance badges without page refresh.
4. **Live KPI Dashboard Cards**: Real-time display of Total Students, Class Average, Highest Score, and Distinction Count.
5. **Client & Server-Side Validation**: Robust bounds-checking preventing negative, non-numeric, or out-of-range marks. Empty fields default gracefully to 0.0.
6. **Database Transactions & UPSERT**: Bulk submission wrapped in `conn.setAutoCommit(false)` with atomic commit and automatic rollback on error.
7. **1-Click Demo Fill**: Quick-fill helper for viva and laboratory demonstrations to populate realistic test marks for unentered students.
8. **Export to CSV**: Instant client-side generation and download of official `.csv` marksheet spreadsheets.
9. **Print-Ready Mark Sheet**: Custom `@media print` stylesheets formatting both faculty marksheet and student grade card for official university records.
10. **Student Self-Service Portal**: Public portal for students to search by university roll number with quick demo click pills and view verified marks across all subjects.

---

## 5. Project Structure
```
InternalMarksManagement/
├── pom.xml                               # Maven Project Descriptor (WAR Packaging)
├── database.sql                          # MySQL Database Schema + 205 Students + Demo Marks
├── README.md                             # Comprehensive Project Documentation
│
└── src/
    └── main/
        ├── java/
        │   └── com/
        │       └── vce/
        │           └── marks/
        │               ├── DBConnection.java     # JDBC Connection Factory
        │               ├── LoginServlet.java     # Faculty Authentication & Logout
        │               ├── MarksServlet.java     # Bulk Marks Roster Load & Transaction Save
        │               └── StudentServlet.java   # Student Roll Number Lookup & Profile
        │
        └── webapp/
            ├── index.jsp                         # Faculty Login + 1-Click Demo Sign-in
            ├── faculty.jsp                       # Faculty Dashboard, KPIs, Table, Actions
            ├── student.jsp                       # Student Grade Portal & Statement View
            ├── css/
            │   └── style.css                     # Premium Design System & Print CSS
            ├── js/
            │   └── script.js                     # Real-time Calculations, KPIs, CSV Export
            └── WEB-INF/
                └── web.xml                       # Servlet & Session Deployment Descriptor
```

---

## 6. Database Architecture
- **Database**: `internal_marks_db`
- **Tables**:
  1. `faculty` (`faculty_id`, `username`, `password`, `name`)
  2. `students` (`student_id`, `roll_no`, `name`, `section`, `department`, `semester`)
  3. `marks` (`mark_id`, `student_id`, `subject`, `assessment`, `cat1_marks`, `cat2_marks`, `cat_average`, `class_test_marks`, `assignment_marks`, `attendance_marks`, `total_internal_marks`, `updated_at`)
- **Key Constraints**:
  - `fk_student_marks`: Foreign Key (`marks.student_id` &rarr; `students.student_id` ON DELETE CASCADE)
  - `uq_student_subject_assessment`: `UNIQUE KEY (student_id, subject, assessment)`

---

## 7. Demo Faculty & Student Credentials
- **Faculty Login**:
  - URL: `http://localhost:8081/InternalMarksManagement/`
  - Username: `faculty`
  - Password: `faculty123`
  - *(Or click the '1-Click Auto Fill & Sign In' button on the login screen)*
- **Demo Student Roll Numbers**:
  - `24881A1245` &bull; Mohammed Maaz Arfaat (Section A)
  - `24881A12B0` &bull; Nadikuda Sathish (Section B)
  - `24881A12H3` &bull; Saddi Amulya Reddy (Section C)
  - `24881A1201` &bull; Section A

---

## 8. Build and Deployment Instructions

### Database Setup
Execute the initialization script in MySQL:
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -psystem < database.sql
```

### Maven Build
```powershell
cd InternalMarksManagement
mvn clean package
```
Generates artifact: `target/InternalMarksManagement.war`.

### Tomcat Deployment
Copy the WAR file into Apache Tomcat 9.0's `webapps` directory:
```powershell
Copy-Item target\InternalMarksManagement.war "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\" -Force
```

### Application URLs
- **Faculty Dashboard / Home**: `http://localhost:8081/InternalMarksManagement/`
- **Student Grade Portal**: `http://localhost:8081/InternalMarksManagement/student`
