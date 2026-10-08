/**
 * Internal Marks Management System - Client-side Logic
 * Department of Information Technology, Vardhaman College of Engineering
 *
 * Continuous Internal Evaluation (CIE) Scheme:
 * CAT Average = (CAT1 + CAT2) / 2 (Max: 30)
 * Internal Total = CAT Average + Class Tests (4) + Assignments (4) + Attendance (2) (Max: 40)
 */

// Maximum component marks (out of 40)
const MAX_MARKS = {
    cat1: 30.0,
    cat2: 30.0,
    cat_avg: 30.0,
    class_test: 4.0,
    assignment: 4.0,
    attendance: 2.0,
    total: 40.0
};

document.addEventListener("DOMContentLoaded", function () {
    initMarksCalculations();
    initStudentSearch();
    initSaveMarksForm();
    initLoginForm();
    initDemoFill();
    initExportCsv();
});

/**
 * Initializes automatic calculation of row totals, live status badges, and class KPI metrics.
 */
function initMarksCalculations() {
    const table = document.getElementById("marksTable");
    if (!table) return;

    // Recalculate all row totals initially
    const rows = table.querySelectorAll("tbody tr");
    rows.forEach(function (row) {
        calculateRowTotal(row, false);
    });
    updateKpiCards();

    // Delegate input change events on the table
    table.addEventListener("input", function (e) {
        if (e.target.classList.contains("mark-input")) {
            validateInput(e.target);
            const row = e.target.closest("tr");
            if (row) {
                calculateRowTotal(row, true);
            }
        }
    });
}

/**
 * Validates a single mark input element against component maximums and ranges.
 */
function validateInput(input) {
    const fieldType = input.getAttribute("data-type");
    const val = parseFloat(input.value);

    let maxVal = 40.0;
    if (fieldType === "cat1") maxVal = MAX_MARKS.cat1;
    else if (fieldType === "cat2") maxVal = MAX_MARKS.cat2;
    else if (fieldType === "class_test") maxVal = MAX_MARKS.class_test;
    else if (fieldType === "assignment") maxVal = MAX_MARKS.assignment;
    else if (fieldType === "attendance") maxVal = MAX_MARKS.attendance;

    if (isNaN(val) || val < 0 || val > maxVal) {
        input.classList.add("input-invalid");
        input.title = "Value must be between 0 and " + maxVal;
        return false;
    } else {
        input.classList.remove("input-invalid");
        input.title = "";
        return true;
    }
}

/**
 * Calculates CAT Average, Internal Total, and Status Badge for a specific student row.
 */
function calculateRowTotal(row, shouldUpdateKpi) {
    const cat1Input = row.querySelector("input[data-type='cat1']");
    const cat2Input = row.querySelector("input[data-type='cat2']");
    const catAvgInput = row.querySelector(".cat-avg-input");
    const classTestInput = row.querySelector("input[data-type='class_test']");
    const assignInput = row.querySelector("input[data-type='assignment']");
    const attInput = row.querySelector("input[data-type='attendance']");
    const totalInput = row.querySelector(".total-input");

    if (!cat1Input || !cat2Input || !classTestInput || !assignInput || !attInput || !totalInput) {
        return;
    }

    const c1 = parseFloat(cat1Input.value) || 0;
    const c2 = parseFloat(cat2Input.value) || 0;
    const ct = parseFloat(classTestInput.value) || 0;
    const a = parseFloat(assignInput.value) || 0;
    const att = parseFloat(attInput.value) || 0;

    const catAvg = Math.min(MAX_MARKS.cat_avg, Math.max(0, (c1 + c2) / 2.0));
    if (catAvgInput) {
        catAvgInput.value = catAvg.toFixed(2);
    }

    const total = Math.min(MAX_MARKS.total, Math.max(0, catAvg + ct + a + att));
    totalInput.value = total.toFixed(2);

    // Update Status Badge in table row
    const statusCell = row.querySelector(".col-status");
    if (statusCell) {
        let badgeHtml = "";
        if (total === 0 && c1 === 0 && c2 === 0 && ct === 0 && a === 0 && att === 0) {
            badgeHtml = '<span class="status-badge status-pending">Pending</span>';
        } else if (total >= 32.0) {
            badgeHtml = '<span class="status-badge status-distinction">Distinction</span>';
        } else if (total >= 24.0) {
            badgeHtml = '<span class="status-badge status-firstclass">First Class</span>';
        } else if (total >= 16.0) {
            badgeHtml = '<span class="status-badge status-pass">Pass</span>';
        } else {
            badgeHtml = '<span class="status-badge status-remedial">Remedial</span>';
        }
        statusCell.innerHTML = badgeHtml;
    }

    if (shouldUpdateKpi) {
        updateKpiCards();
    }
}

/**
 * Updates dynamic KPI summary metrics on the faculty dashboard.
 */
function updateKpiCards() {
    const table = document.getElementById("marksTable");
    if (!table) return;

    const rows = table.querySelectorAll("tbody tr");
    let totalCount = 0;
    let evaluatedCount = 0;
    let sumTotal = 0;
    let highest = 0;
    let distinctionCount = 0;

    rows.forEach(function (row) {
        const totalInput = row.querySelector(".total-input");
        if (!totalInput) return;
        totalCount++;

        const val = parseFloat(totalInput.value) || 0;
        if (val > 0) {
            evaluatedCount++;
            sumTotal += val;
            if (val > highest) highest = val;
            if (val >= 32.0) distinctionCount++;
        }
    });

    const kpiTotal = document.getElementById("kpiTotalStudents");
    const kpiAvg = document.getElementById("kpiClassAvg");
    const kpiHigh = document.getElementById("kpiHighestScore");
    const kpiDist = document.getElementById("kpiDistinction");

    if (kpiTotal) kpiTotal.textContent = totalCount;
    if (kpiAvg) {
        const avg = evaluatedCount > 0 ? (sumTotal / evaluatedCount).toFixed(2) : "0.00";
        kpiAvg.textContent = avg + " / 40";
    }
    if (kpiHigh) kpiHigh.textContent = highest.toFixed(2) + " / 40";
    if (kpiDist) kpiDist.textContent = distinctionCount + " of " + evaluatedCount;
}

/**
 * Real-time student search/filter by Roll Number or Student Name.
 */
function initStudentSearch() {
    const searchInput = document.getElementById("studentSearch");
    const table = document.getElementById("marksTable");
    const countDisplay = document.getElementById("visibleCountDisplay");

    if (!searchInput || !table) return;

    searchInput.addEventListener("input", function () {
        const query = searchInput.value.trim().toLowerCase();
        const rows = table.querySelectorAll("tbody tr");
        let visibleCount = 0;

        rows.forEach(function (row) {
            const rollCell = row.querySelector(".col-roll");
            const nameCell = row.querySelector(".col-name");

            const rollText = rollCell ? rollCell.textContent.toLowerCase() : "";
            const nameText = nameCell ? nameCell.textContent.toLowerCase() : "";

            if (rollText.includes(query) || nameText.includes(query)) {
                row.style.display = "";
                visibleCount++;
            } else {
                row.style.display = "none";
            }
        });

        if (countDisplay) {
            countDisplay.textContent = "Showing " + visibleCount + " of " + rows.length + " students";
        }
    });
}

/**
 * Provides an auto-fill helper for demo presentations to populate realistic marks.
 */
function initDemoFill() {
    const btn = document.getElementById("btnFillDemo");
    if (!btn) return;

    btn.addEventListener("click", function () {
        const table = document.getElementById("marksTable");
        if (!table) return;

        const rows = table.querySelectorAll("tbody tr");
        let filledCount = 0;

        rows.forEach(function (row, idx) {
            const cat1Input = row.querySelector("input[data-type='cat1']");
            const cat2Input = row.querySelector("input[data-type='cat2']");
            const classTestInput = row.querySelector("input[data-type='class_test']");
            const assignInput = row.querySelector("input[data-type='assignment']");
            const attInput = row.querySelector("input[data-type='attendance']");
            const totalInput = row.querySelector(".total-input");

            if (!cat1Input || !cat2Input || !classTestInput || !assignInput || !attInput || !totalInput) return;

            const currentTotal = parseFloat(totalInput.value) || 0;
            // Fill if unentered or zero
            if (currentTotal === 0) {
                const baseCat1 = 23 + ((idx * 3) % 7);
                const baseCat2 = 24 + ((idx * 2) % 6);
                const baseCt = 3.0 + ((idx % 3) * 0.5);
                const baseAssign = 3.5 + ((idx % 2) * 0.5);
                const baseAtt = 1.5 + ((idx % 2) * 0.5);

                cat1Input.value = baseCat1.toFixed(1);
                cat2Input.value = baseCat2.toFixed(1);
                classTestInput.value = baseCt.toFixed(1);
                assignInput.value = baseAssign.toFixed(1);
                attInput.value = baseAtt.toFixed(1);

                calculateRowTotal(row, false);
                filledCount++;
            }
        });

        updateKpiCards();

        if (filledCount > 0) {
            alert("Populated realistic marks for " + filledCount + " students. Click 'SAVE ALL MARKS' to save into MySQL database.");
        } else {
            alert("All students in this section already have marks entered.");
        }
    });
}

/**
 * Exports current section assessment marks directly to CSV format.
 */
function initExportCsv() {
    const btn = document.getElementById("btnExportCsv");
    if (!btn) return;

    btn.addEventListener("click", function () {
        const table = document.getElementById("marksTable");
        if (!table) return;

        const sectionSelect = document.getElementById("sectionSelect");
        const section = sectionSelect ? sectionSelect.value : "A";
        const subjectSelect = document.getElementById("subjectSelect");
        const subject = subjectSelect ? subjectSelect.value : "Web_Technologies";

        let csv = [];
        csv.push(["Internal Marks Management System - Vardhaman College of Engineering"]);
        csv.push(["Subject:", '"' + subject + '"', "Section:", section, "Max Marks:", "40"]);
        csv.push([]);
        csv.push(["S.No", "Roll Number", "Student Name", "CAT 1 (30)", "CAT 2 (30)", "CAT Avg (30)", "Class Tests (4)", "Assignments (4)", "Attendance (2)", "Internal Total (40)", "Academic Status"]);

        const rows = table.querySelectorAll("tbody tr");
        rows.forEach(function (row, idx) {
            const rollCell = row.querySelector(".col-roll");
            const nameCell = row.querySelector(".col-name");
            const cat1 = row.querySelector("input[data-type='cat1']")?.value || "0";
            const cat2 = row.querySelector("input[data-type='cat2']")?.value || "0";
            const catAvg = row.querySelector(".cat-avg-input")?.value || "0";
            const ct = row.querySelector("input[data-type='class_test']")?.value || "0";
            const assign = row.querySelector("input[data-type='assignment']")?.value || "0";
            const att = row.querySelector("input[data-type='attendance']")?.value || "0";
            const total = row.querySelector(".total-input")?.value || "0";
            const status = row.querySelector(".status-badge")?.textContent || "Pending";

            if (rollCell && nameCell) {
                const roll = rollCell.textContent.trim();
                const name = '"' + nameCell.textContent.trim().replace(/"/g, '""') + '"';
                csv.push([idx + 1, roll, name, cat1, cat2, catAvg, ct, assign, att, total, status]);
            }
        });

        const csvString = csv.map(e => e.join(",")).join("\n");
        const blob = new Blob([csvString], { type: "text/csv;charset=utf-8;" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "Marks_" + subject.replace(/\s+/g, "_") + "_Section_" + section + ".csv";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    });
}

/**
 * Handles confirmation and client-side validation prior to saving marks.
 */
function initSaveMarksForm() {
    const saveForm = document.getElementById("marksEntryForm");
    if (!saveForm) return;

    saveForm.addEventListener("submit", function (e) {
        const table = document.getElementById("marksTable");
        if (!table) return;

        const inputs = table.querySelectorAll(".mark-input");
        let hasErrors = false;
        let firstErrorInput = null;

        inputs.forEach(function (input) {
            if (!validateInput(input)) {
                hasErrors = true;
                if (!firstErrorInput) firstErrorInput = input;
            }
        });

        if (hasErrors) {
            e.preventDefault();
            alert("Validation Error: One or more marks are invalid (negative, non-numeric, or exceeding maximum allowed limit: CAT1/30, CAT2/30, Class Tests/4, Assignments/4, Attendance/2, Total/40). Please review highlighted fields.");
            if (firstErrorInput) {
                firstErrorInput.focus();
            }
            return false;
        }

        const sectionSelect = document.getElementById("sectionSelect");
        const sectionName = sectionSelect ? sectionSelect.value : "selected section";
        const subjectSelect = document.getElementById("subjectSelect");
        const subjectName = subjectSelect ? subjectSelect.value : "selected subject";

        const confirmed = confirm(
            "Confirm Save Marks:\n\n" +
            "Save internal assessment marks for Section " + sectionName + " (" + subjectName + ")?\n" +
            "This will insert new records and update existing student marks in the database."
        );

        if (!confirmed) {
            e.preventDefault();
            return false;
        }
    });
}

/**
 * Validates the login form.
 */
function initLoginForm() {
    const loginForm = document.getElementById("loginForm");
    if (!loginForm) return;

    loginForm.addEventListener("submit", function (e) {
        const usernameInput = document.getElementById("username");
        const passwordInput = document.getElementById("password");

        if (!usernameInput || !passwordInput) return;

        if (usernameInput.value.trim() === "" || passwordInput.value.trim() === "") {
            e.preventDefault();
            alert("Please enter both username and password.");
            if (usernameInput.value.trim() === "") {
                usernameInput.focus();
            } else {
                passwordInput.focus();
            }
        }
    });
}

/**
 * Global helper for quick demo roll number selection in student.jsp.
 */
function selectDemoRoll(roll) {
    const input = document.getElementById("studentRollInput");
    const form = document.getElementById("studentSearchForm");
    if (input && form) {
        input.value = roll;
        form.submit();
    }
}

/**
 * Global helper for 1-click demo faculty login in index.jsp.
 */
function quickFacultyLogin() {
    const user = document.getElementById("username");
    const pass = document.getElementById("password");
    const form = document.getElementById("loginForm");
    if (user && pass && form) {
        user.value = "faculty";
        pass.value = "faculty123";
        form.submit();
    }
}

/**
 * Branch-to-Sections mapping dictionary.
 */
const BRANCH_SECTIONS_CONFIG = {
    "CSE": ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
    "CSM": ["A", "B", "C"],
    "CSD": ["A", "B", "C"],
    "ECE": ["A", "B", "C"],
    "IT":  ["A", "B", "C"],
    "EEE": ["A"],
    "MECH": ["A"],
    "CIVIL": ["A"]
};

/**
 * Switches between Manual Marks Entry and Excel Import tabs.
 */
function switchFacultyTab(tabName) {
    const manualPanel = document.getElementById("manualEntryPanel");
    const excelPanel = document.getElementById("excelImportPanel");
    const manualBtn = document.getElementById("tabManualBtn");
    const excelBtn = document.getElementById("tabExcelBtn");

    if (tabName === "excel") {
        if (manualPanel) manualPanel.style.display = "none";
        if (excelPanel) excelPanel.style.display = "block";
        if (manualBtn) manualBtn.classList.remove("active");
        if (excelBtn) excelBtn.classList.add("active");
    } else {
        if (manualPanel) manualPanel.style.display = "block";
        if (excelPanel) excelPanel.style.display = "none";
        if (manualBtn) manualBtn.classList.add("active");
        if (excelBtn) excelBtn.classList.remove("active");
    }
}

/**
 * Handles Branch dropdown change in the main filter bar.
 */
function onFilterBranchChange() {
    const branchSel = document.getElementById("branchSelect");
    const secSel = document.getElementById("sectionSelect");
    if (!branchSel || !secSel) return;

    const branch = branchSel.value;
    const sections = BRANCH_SECTIONS_CONFIG[branch] || ["A"];
    const currentSec = secSel.value;

    secSel.innerHTML = "";
    sections.forEach(function (sec) {
        const opt = document.createElement("option");
        opt.value = sec;
        opt.textContent = "Section " + sec;
        if (sec === currentSec) {
            opt.selected = true;
        }
        secSel.appendChild(opt);
    });
    if (!sections.includes(currentSec)) {
        secSel.value = sections[0];
    }
}

/**
 * Handles Branch dropdown change in the Excel Upload form.
 */
function onExcelBranchChange() {
    const branchSel = document.getElementById("excelBranchSelect");
    const secSel = document.getElementById("excelSectionSelect");
    if (!branchSel || !secSel) return;

    const branch = branchSel.value;
    const sections = BRANCH_SECTIONS_CONFIG[branch] || ["A"];
    const currentSec = secSel.value;

    secSel.innerHTML = "";
    sections.forEach(function (sec) {
        const opt = document.createElement("option");
        opt.value = sec;
        opt.textContent = "Section " + sec;
        if (sec === currentSec) {
            opt.selected = true;
        }
        secSel.appendChild(opt);
    });
    if (!sections.includes(currentSec)) {
        secSel.value = sections[0];
    }

    updateTemplateDownloadLink();
}

/**
 * Dynamically updates the "Download Excel Template" link with selected branch, section, and subject.
 */
function updateTemplateDownloadLink() {
    const btn = document.getElementById("btnDownloadTemplate");
    if (!btn) return;

    const branchSel = document.getElementById("excelBranchSelect") || document.getElementById("branchSelect");
    const secSel = document.getElementById("excelSectionSelect") || document.getElementById("sectionSelect");
    const subjSel = document.getElementById("excelSubjectSelect") || document.getElementById("subjectSelect");

    const branch = branchSel ? branchSel.value : "IT";
    const sec = secSel ? secSel.value : "A";
    const subj = subjSel ? encodeURIComponent(subjSel.value) : "Web+Technologies";

    const contextPath = btn.getAttribute("data-context") || "";
    btn.href = contextPath + "/marks?action=download_template&branch=" + branch + "&section=" + sec + "&subject=" + subj;
}

/**
 * Validates and submits the Excel upload form for Preview & Validate.
 */
function submitExcelPreview() {
    const fileInput = document.getElementById("excelFileInput");
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("Please choose a valid .xlsx Excel file to preview and validate.");
        fileInput.focus();
        return;
    }
    const fileName = fileInput.files[0].name.toLowerCase();
    if (!fileName.endsWith(".xlsx")) {
        alert("Only Excel files with .xlsx extension are supported.");
        return;
    }

    const actionInput = document.getElementById("excelActionInput");
    if (actionInput) actionInput.value = "preview_excel";

    const form = document.getElementById("excelUploadForm");
    if (form) form.submit();
}

/**
 * Validates and submits the Excel upload form for Import & Save to MySQL.
 */
function submitExcelImport() {
    const fileInput = document.getElementById("excelFileInput");
    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        alert("Please choose a valid .xlsx Excel file to import.");
        fileInput.focus();
        return;
    }
    const fileName = fileInput.files[0].name.toLowerCase();
    if (!fileName.endsWith(".xlsx")) {
        alert("Only Excel files with .xlsx extension are supported.");
        return;
    }

    const actionInput = document.getElementById("excelActionInput");
    if (actionInput) actionInput.value = "import_excel";

    const form = document.getElementById("excelUploadForm");
    if (form) form.submit();
}

