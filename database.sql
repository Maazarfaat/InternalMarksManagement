-- WARNING: Running this initialization script recreates the project tables and removes existing marks.
-- ========================================================
-- DATABASE INITIALIZATION SCRIPT
-- Project: INTERNAL MARKS MANAGEMENT SYSTEM
-- Course: Web Technologies Laboratory (A8605)
-- Database: internal_marks_db
-- ========================================================

CREATE DATABASE IF NOT EXISTS internal_marks_db;
USE internal_marks_db;

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS marks;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS faculty;

-- TABLE 1: faculty
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Faculty Demo Login Credentials
INSERT INTO faculty (username, password, name) VALUES ('faculty', 'faculty123', 'Faculty Member');

-- TABLE 2: students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    roll_no VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    section VARCHAR(5) NOT NULL,
    department VARCHAR(20) NOT NULL DEFAULT 'IT',
    semester INT NOT NULL DEFAULT 5
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TABLE 3: marks
CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    assessment VARCHAR(100) NOT NULL,
    cat1_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    cat2_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    cat_average DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    class_test_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    assignment_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    attendance_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    total_internal_marks DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_marks FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT uq_student_subject_assessment UNIQUE (student_id, subject, assessment)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- STUDENT DATA IMPORT (From WT COURSE END PROJECTS LIST.pdf)
-- Team Member 1 -> Section A
-- Team Member 2 -> Section B
-- Team Member 3 -> Section C
-- Department: IT, Semester: 5
-- ========================================================
INSERT INTO students (roll_no, name, section, department, semester) VALUES
('24881A1201', 'Allapuram Abhignya Reddy', 'A', 'IT', 5),
('24881A1265', 'Addula Prathika Reddy', 'B', 'IT', 5),
('24881A12C8', 'Acha Jyothika', 'C', 'IT', 5),
('24881A1202', 'Amgoth Lokesh', 'A', 'IT', 5),
('24881A1266', 'Aili Rajesh', 'B', 'IT', 5),
('24881A12C9', 'Akshat Bhatnagar', 'C', 'IT', 5),
('24881A1203', 'Aniket Samanta', 'A', 'IT', 5),
('24881A1267', 'Alakanti Varsha', 'B', 'IT', 5),
('24881A12D0', 'Anireddy Anugnya Reddy', 'C', 'IT', 5),
('24881A1204', 'Ansar', 'A', 'IT', 5),
('24881A1269', 'Apuri Shivani', 'B', 'IT', 5),
('24881A12D1', 'Arijala Nithisha Reddy', 'C', 'IT', 5),
('24881A1205', 'Anushka Sugandhi', 'A', 'IT', 5),
('24881A1270', 'Ayman Nijamuddeen', 'B', 'IT', 5),
('24881A12D2', 'Bandameedi Chandravardhan', 'C', 'IT', 5),
('24881A1206', 'Atakula Hasini', 'A', 'IT', 5),
('24881A1271', 'B Gayathri', 'B', 'IT', 5),
('24881A12D3', 'Bysani Kshema', 'C', 'IT', 5),
('24881A1207', 'B Sai Charan Reddy', 'A', 'IT', 5),
('24881A1272', 'Baikani Akshitha', 'B', 'IT', 5),
('24881A12D4', 'Chatla Sunnith', 'C', 'IT', 5),
('24881A1208', 'Baddepaka Vijay', 'A', 'IT', 5),
('24881A1273', 'Banda Supritha', 'B', 'IT', 5),
('24881A12D5', 'Chigirintha Honey Reddy', 'C', 'IT', 5),
('24881A1209', 'Bala Vamshi Krishna', 'A', 'IT', 5),
('24881A1274', 'Bandlamudi Pavani', 'B', 'IT', 5),
('24881A12D6', 'Chithari Vignesh', 'C', 'IT', 5),
('24881A1210', 'Banda Sushmitha', 'A', 'IT', 5),
('24881A1275', 'Bantrapu Mahesh Goud', 'B', 'IT', 5),
('24881A12D7', 'Darapuneni Jyoshnasri', 'C', 'IT', 5),
('24881A1211', 'Bandi Pooja Sri', 'A', 'IT', 5),
('24881A1276', 'Barre Chiranjeevi', 'B', 'IT', 5),
('24881A12D8', 'Dasarla Akshitha', 'C', 'IT', 5),
('24881A1212', 'Barla Sathya Charan', 'A', 'IT', 5),
('24881A1277', 'Bathuka Naveen', 'B', 'IT', 5),
('24881A12D9', 'Dubbaka Abhinay', 'C', 'IT', 5),
('24881A1213', 'Baswa Vignesh', 'A', 'IT', 5),
('24881A1278', 'Battu Sri Mani Harika', 'B', 'IT', 5),
('24881A12E0', 'Dugyala Sahasrara', 'C', 'IT', 5),
('24881A1214', 'Bejjarapu Shivasai Vivek', 'A', 'IT', 5),
('24881A1279', 'Bayolla Sai Keerthan', 'B', 'IT', 5),
('24881A12E1', 'Gaini Vinay Kumar', 'C', 'IT', 5),
('24881A1215', 'Bhukya Lokesh Naik', 'A', 'IT', 5),
('24881A1280', 'Boinipelli Rakshith Rao', 'B', 'IT', 5),
('24881A12E3', 'Geesa Shiva Balaji', 'C', 'IT', 5),
('24881A1216', 'Burra Manish Goud', 'A', 'IT', 5),
('24881A1281', 'Bojjireddy Aravind Reddy', 'B', 'IT', 5),
('24881A12E4', 'Golla Abhilash', 'C', 'IT', 5),
('24881A1217', 'Caleb Ruhan Dawson', 'A', 'IT', 5),
('24881A1282', 'Chakali Yamini', 'B', 'IT', 5),
('24881A12E5', 'Gullapalli Pradeep Akilesh', 'C', 'IT', 5),
('24881A1218', 'Chenna Naveen Kumar', 'A', 'IT', 5),
('24881A1283', 'Chanda Bhargavi', 'B', 'IT', 5),
('24881A12E6', 'Gummadi Hanisha', 'C', 'IT', 5),
('24881A1219', 'Derangula Kiran Sairam Teja', 'A', 'IT', 5),
('24881A1284', 'Charaka Amulya', 'B', 'IT', 5),
('24881A12E7', 'Hanumanthula Abhilash Goud', 'C', 'IT', 5),
('24881A1220', 'Dharavath Srikanth', 'A', 'IT', 5),
('24881A1285', 'Cheeti Keerthana', 'B', 'IT', 5),
('24881A12E8', 'Harshit Kumar Gudla', 'C', 'IT', 5),
('24881A1221', 'Engle Shivaji', 'A', 'IT', 5),
('24881A1286', 'Chilamakuri Haneesh Balaji', 'B', 'IT', 5),
('24881A12E9', 'K Jyothi', 'C', 'IT', 5),
('24881A1222', 'Gankidi Vishnuvardhan Reddy', 'A', 'IT', 5),
('24881A1287', 'Chintamaduka Ashish', 'B', 'IT', 5),
('24881A12F0', 'K Vishnu Vardhan', 'C', 'IT', 5),
('24881A1223', 'Gattu Rithvik', 'A', 'IT', 5),
('24881A1288', 'Doma Shashank', 'B', 'IT', 5),
('24881A12F1', 'Kakaraparthi Gandi Ganesh', 'C', 'IT', 5),
('24881A1224', 'Gondela Madhuri', 'A', 'IT', 5),
('24881A1289', 'Dunde Archana', 'B', 'IT', 5),
('24881A12F2', 'Kanike Sreevalli', 'C', 'IT', 5),
('24881A1225', 'Gondi Manasvi Reddy', 'A', 'IT', 5),
('24881A1290', 'Gudimalla Rohith', 'B', 'IT', 5),
('24881A12F3', 'Kankanti Kavya Sree', 'C', 'IT', 5),
('24881A1226', 'Gudapureddy Venkata Suseel Kumar', 'A', 'IT', 5),
('24881A1291', 'Jabbu Amulya', 'B', 'IT', 5),
('24881A12F4', 'Kethavath Santhosh', 'C', 'IT', 5),
('24881A1227', 'Guduru Sidharth Reddy', 'A', 'IT', 5),
('24881A1292', 'Jai Aditya Varikuti', 'B', 'IT', 5),
('24881A12F5', 'Khammam Yakshitha', 'C', 'IT', 5),
('24881A1228', 'Kappala Sai Ganesh', 'A', 'IT', 5),
('24881A1293', 'Jayarapu Gouthami', 'B', 'IT', 5),
('24881A12F6', 'Komari Prathik Kumar', 'C', 'IT', 5),
('24881A1229', 'Kasthuri Purushotham', 'A', 'IT', 5),
('24881A1294', 'Kakkireni Deekshitha', 'B', 'IT', 5),
('24881A12F7', 'Korra Ganesh', 'C', 'IT', 5),
('24881A1230', 'Katla Akshara', 'A', 'IT', 5),
('24881A1295', 'Kalakada Thekshitha', 'B', 'IT', 5),
('24881A12F8', 'Kurva Mallesh', 'C', 'IT', 5),
('24881A1231', 'Kavali Sai Manoj Kumar', 'A', 'IT', 5),
('24881A1296', 'Kallem Sahasra', 'B', 'IT', 5),
('24881A12F9', 'Lahari Madaramoni', 'C', 'IT', 5),
('24881A1232', 'Kethavath Sandhya', 'A', 'IT', 5),
('24881A1297', 'Kiladi Shiva Prasanna', 'B', 'IT', 5),
('24881A12G0', 'Lingampally Pranavi', 'C', 'IT', 5),
('24881A1233', 'Kodam Tejaswi', 'A', 'IT', 5),
('24881A1298', 'Kondapally Srikar', 'B', 'IT', 5),
('24881A12G1', 'Manchukonda Dheeraj', 'C', 'IT', 5),
('24881A1234', 'Kokku Arun', 'A', 'IT', 5),
('24881A1299', 'Lonavath Nandini', 'B', 'IT', 5),
('24881A12G2', 'Modi Vamshi Vardhan', 'C', 'IT', 5),
('24881A1235', 'Komatireddy Bhavani', 'A', 'IT', 5),
('24881A12A0', 'Manchiryala Rushi Chandra', 'B', 'IT', 5),
('24881A12G3', 'Modusu Vasavi', 'C', 'IT', 5),
('24881A1236', 'Kona Varshit Ram', 'A', 'IT', 5),
('24881A12A1', 'Mandhula Nikhitha', 'B', 'IT', 5),
('24881A12G4', 'Mukiri Aparna', 'C', 'IT', 5),
('24881A1237', 'Kukkali Varshitha', 'A', 'IT', 5),
('24881A12A2', 'Maram Dhanush Reddy', 'B', 'IT', 5),
('24881A12G5', 'Murari Shetti Anirudh', 'C', 'IT', 5),
('24881A1238', 'Kummari Pallavi', 'A', 'IT', 5),
('24881A12A3', 'Merugu Akhila', 'B', 'IT', 5),
('24881A12G6', 'Narla Shiva Shankar', 'C', 'IT', 5),
('24881A1239', 'Kummari Varunsandesh', 'A', 'IT', 5),
('24881A12A4', 'Merugu Remalyacharmiyana', 'B', 'IT', 5),
('24881A12G7', 'Neeli Maniraj', 'C', 'IT', 5),
('24881A1240', 'Kushangala Siddharth', 'A', 'IT', 5),
('24881A12A5', 'Mir Owaiseuddin Baseer', 'B', 'IT', 5),
('24881A12G8', 'Neerati Bhanu Prasad', 'C', 'IT', 5),
('24881A1241', 'Maheshwaram Harishankar Chary', 'A', 'IT', 5),
('24881A12A6', 'Mohammed Affaan', 'B', 'IT', 5),
('24881A12G9', 'Pattem Guru Dharani Krushna', 'C', 'IT', 5),
('24881A1242', 'Manchala Uday Kumar', 'A', 'IT', 5),
('24881A12A7', 'Murthati Japaraju', 'B', 'IT', 5),
('24881A12H0', 'Rajula Shiva', 'C', 'IT', 5),
('24881A1243', 'Mittapally Vinuthna', 'A', 'IT', 5),
('24881A12A8', 'Muthe Sathwik Varma', 'B', 'IT', 5),
('24881A12H1', 'Ramaswamy Venugopal Reddy', 'C', 'IT', 5),
('24881A1244', 'Mohammed Farhan Arshad', 'A', 'IT', 5),
('24881A12A9', 'Mylarishetty Vishal', 'B', 'IT', 5),
('24881A12H2', 'Rayapuri Charan', 'C', 'IT', 5),
('24881A1245', 'Mohammed Maaz Arfaat', 'A', 'IT', 5),
('24881A12B0', 'Nadikuda Sathish', 'B', 'IT', 5),
('24881A12H3', 'Saddi Amulya Reddy', 'C', 'IT', 5),
('24881A1246', 'Mudavath Kavitha', 'A', 'IT', 5),
('24881A12B1', 'Nenavath Swapna', 'B', 'IT', 5),
('24881A12H4', 'Seelam Sindhu Reddy', 'C', 'IT', 5),
('24881A1247', 'Pajjuri Bhavishya', 'A', 'IT', 5),
('24881A12B2', 'Oggu Santhosh', 'B', 'IT', 5),
('24881A12H5', 'Shankarampet Manudeep Reddy', 'C', 'IT', 5),
('24881A1248', 'Palreddy Sahithi', 'A', 'IT', 5),
('24881A12B3', 'Pagadala Harsha Vardhan Sai', 'B', 'IT', 5),
('24881A12H6', 'Sirigiri Shashikumar', 'C', 'IT', 5),
('24881A1249', 'Parvathala Akshith Kumar', 'A', 'IT', 5),
('24881A12B4', 'Pakala Sanjana', 'B', 'IT', 5),
('24881A12H7', 'Tanguturi Dattathreya', 'C', 'IT', 5),
('24881A1250', 'Patllolla Harshitha Reddy', 'A', 'IT', 5),
('24881A12B5', 'Pakide Ram Charan', 'B', 'IT', 5),
('24881A12H8', 'Tatineni Sai Geethika', 'C', 'IT', 5),
('24881A1251', 'Patlolla Rishitha Reddy', 'A', 'IT', 5),
('24881A12B6', 'Perugu Hema Priya', 'B', 'IT', 5),
('24881A12H9', 'Tippani Akhil Reddy', 'C', 'IT', 5),
('24881A1252', 'Pole Raviteja', 'A', 'IT', 5),
('24881A12B7', 'Podugu Chetan Kumar', 'B', 'IT', 5),
('24881A12J0', 'Tumma Krishna Chandra', 'C', 'IT', 5),
('24881A1253', 'Rangineni Pavani', 'A', 'IT', 5),
('24881A12B8', 'Prasadam Sreevarsha', 'B', 'IT', 5),
('24881A12J1', 'Upper Yashaswini', 'C', 'IT', 5),
('24881A1254', 'Reddy Harika', 'A', 'IT', 5),
('24881A12B9', 'Rathod Sanjeev', 'B', 'IT', 5),
('24881A12J3', 'Vadlakonda Mayuri', 'C', 'IT', 5),
('24881A1255', 'Sada Harshith Reddy', 'A', 'IT', 5),
('24881A12C0', 'Somi Reddy Hareeshwar Reddy', 'B', 'IT', 5),
('24881A12J4', 'Vadthya Vennela', 'C', 'IT', 5),
('24881A1256', 'Sanem Rithisha', 'A', 'IT', 5),
('24881A12C1', 'Thalari Goutham', 'B', 'IT', 5),
('24881A12J5', 'Vaishnavi Tiwari', 'C', 'IT', 5),
('24881A1257', 'Siddamshetty Sai Teja', 'A', 'IT', 5),
('24881A12C2', 'Thudi Sampath Kumar Reddy', 'B', 'IT', 5),
('24881A12J6', 'Vasa Nikitha', 'C', 'IT', 5),
('24881A1259', 'Surasani Srinidhi', 'A', 'IT', 5),
('24881A12C4', 'Vadla Basvaraj', 'B', 'IT', 5),
('24881A12J7', 'Vedire Bhavya', 'C', 'IT', 5),
('24881A1260', 'Vakkala Sunil', 'A', 'IT', 5),
('24881A12C5', 'Vangeti Likithnandan', 'B', 'IT', 5),
('24881A12J8', 'Velagapalli Merlyn', 'C', 'IT', 5),
('24881A1261', 'Vardhan Vanga', 'A', 'IT', 5),
('24881A12C6', 'Voruganti Rahul', 'B', 'IT', 5),
('24881A12J9', 'Vittedi Chakri', 'C', 'IT', 5),
('24881A1262', 'Vuna Mythri', 'A', 'IT', 5),
('24881A12C7', 'Yendapally Advitha', 'B', 'IT', 5),
('24881A12K0', 'Yambari Avinash', 'C', 'IT', 5),
('24881A1263', 'Yamala Yaswanth Sai', 'A', 'IT', 5),
('25885A1208', 'Chagonda Poojitha', 'B', 'IT', 5),
('25885A1215', 'Angala Abhinaya', 'C', 'IT', 5),
('24881A1264', 'Yepuru Cherish', 'A', 'IT', 5),
('25885A1209', 'Karugam Vaishnavi', 'B', 'IT', 5),
('25885A1216', 'Borra Karthik', 'C', 'IT', 5),
('25885A1201', 'Bhuneti Venu Gopal Goud', 'A', 'IT', 5),
('25885A1210', 'Kummari Arun Kumar', 'B', 'IT', 5),
('25885A1217', 'Devu Akshaya', 'C', 'IT', 5),
('25885A1202', 'Burugu Yashwanth', 'A', 'IT', 5),
('25885A1211', 'Nadkuda Raghavi', 'B', 'IT', 5),
('25885A1218', 'Gouda Bhavani', 'C', 'IT', 5),
('25885A1203', 'Dubala Siddartha', 'A', 'IT', 5),
('25885A1212', 'Sampangi Manoj', 'B', 'IT', 5),
('25885A1219', 'Rudroju Sai Kruthi', 'C', 'IT', 5),
('25885A1204', 'E Lavan Kumar Naidu', 'A', 'IT', 5),
('25885A1213', 'Shaik Sameer', 'B', 'IT', 5),
('25885A1220', 'Vinay Kumar Bommoju', 'C', 'IT', 5),
('25885A1205', 'Pullagurala Pooja Reddy', 'A', 'IT', 5),
('25885A1214', 'Vallapudasu Sneha', 'B', 'IT', 5),
('25885A1206', 'Ramatenki Raghuveer', 'A', 'IT', 5),
('25885A1207', 'S Karthik', 'A', 'IT', 5);

-- ========================================================
-- SAMPLE DEMO MARKS (Internal Assessment 1 - Out of 40)
-- Formula: CAT Avg (30) + Class Tests (4) + Assignments (4) + Attendance (2) = Internal Total (40)
-- ========================================================
INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 28.00, 29.00, 28.50, 4.00, 4.00, 2.00, 38.50 FROM students WHERE roll_no = '24881A1245'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Data Science', 'Internal Assessment 1', 27.00, 28.00, 27.50, 4.00, 3.50, 2.00, 37.00 FROM students WHERE roll_no = '24881A1245'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 26.50, 27.50, 27.00, 3.50, 4.00, 2.00, 36.50 FROM students WHERE roll_no = '24881A12B0'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 29.00, 28.00, 28.50, 4.00, 4.00, 2.00, 38.50 FROM students WHERE roll_no = '24881A12H3'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 25.00, 26.00, 25.50, 3.50, 3.50, 2.00, 34.50 FROM students WHERE roll_no = '24881A1201'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 24.00, 25.00, 24.50, 3.00, 3.50, 1.50, 32.50 FROM students WHERE roll_no = '24881A1265'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

INSERT INTO marks (student_id, subject, assessment, cat1_marks, cat2_marks, cat_average, class_test_marks, assignment_marks, attendance_marks, total_internal_marks)
SELECT student_id, 'Web Technologies', 'Internal Assessment 1', 27.50, 26.50, 27.00, 4.00, 3.50, 2.00, 36.50 FROM students WHERE roll_no = '24881A12C8'
ON DUPLICATE KEY UPDATE total_internal_marks = VALUES(total_internal_marks);

-- Verification Queries
-- SELECT section, COUNT(*) FROM students GROUP BY section ORDER BY section;
-- SELECT m.*, s.roll_no, s.name, s.section FROM marks m JOIN students s ON m.student_id = s.student_id;
