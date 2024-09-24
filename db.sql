-- tao database
CREATE TABLE IF NOT EXISTS exam_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidate_number VARCHAR(255) NOT NULL,
    mon_toan DECIMAL(4,2),
    mon_van DECIMAL(4,2),
    mon_ly DECIMAL(4,2),
    mon_hoa DECIMAL(4,2),
    mon_sinh DECIMAL(4,2),
    mon_su DECIMAL(4,2),
    mon_dia DECIMAL(4,2),
    mon_gdcd DECIMAL(4,2),
    mon_ngoaingu DECIMAL(4,2),
    ma_mon_ngoai_ngu VARCHAR(255),
    mark_info TEXT,
    data_year YEAR,
    UNIQUE(candidate_number)
);
-- chuyển về utf8mb4
ALTER TABLE exam_results CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- khối xét tuyển
-- tạo bảng khối xét tuyển
CREATE TABLE IF NOT EXISTS exam_scores (
    candidate_number VARCHAR(255) PRIMARY KEY,
    block_A00 DECIMAL(4,2),
    block_A01 DECIMAL(4,2),
    block_B00 DECIMAL(4,2),
    block_C00 DECIMAL(4,2),
    block_D01 DECIMAL(4,2)
);
-- tính toán và thêm dữ liệu vào bảng khối xét tuyển
INSERT INTO exam_scores (candidate_number, block_A00, block_A01, block_B00, block_C00, block_D01)
SELECT candidate_number,
    CASE 
        WHEN mon_toan = -1 OR mon_ly = -1 OR mon_hoa = -1 THEN -1 
        ELSE mon_toan + mon_ly + mon_hoa 
    END AS block_A00,
    CASE 
        WHEN mon_toan = -1 OR mon_ly = -1 OR mon_ngoaingu = -1 THEN -1 
        ELSE mon_toan + mon_ly + mon_ngoaingu
    END AS block_A01,
    CASE 
        WHEN mon_toan = -1 OR mon_hoa = -1 OR mon_sinh = -1 THEN -1 
        ELSE mon_toan + mon_hoa + mon_sinh 
    END AS block_B00,
    CASE 
        WHEN mon_van = -1 OR mon_su = -1 OR mon_dia = -1 THEN -1 
        ELSE mon_van + mon_su + mon_dia 
    END AS block_C00,
    CASE 
        WHEN mon_toan = -1 OR mon_van = -1 OR mon_ngoaingu = -1 THEN -1 
        ELSE mon_toan + mon_van + mon_ngoaingu 
    END AS block_D01
FROM exam_results;
-- tạo bảng điểm 10 các môn
CREATE TABLE IF NOT EXISTS exam_scores_10 (
    subject_name VARCHAR(50) PRIMARY KEY,
    count_10 INT
);
-- tính toán và thêm dữ liệu vào bảng điểm 10 các môn
INSERT INTO exam_scores_10 (subject_name, count_10)
SELECT subject, SUM(CASE WHEN score = 10 THEN 1 ELSE 0 END)
FROM (
    SELECT 'mon_toan' AS subject, mon_toan AS score FROM exam_results
    UNION ALL
    SELECT 'mon_van', mon_van FROM exam_results
    UNION ALL
    SELECT 'mon_ly', mon_ly FROM exam_results
    UNION ALL
    SELECT 'mon_hoa', mon_hoa FROM exam_results
    UNION ALL
    SELECT 'mon_sinh', mon_sinh FROM exam_results
    UNION ALL
    SELECT 'mon_su', mon_su FROM exam_results
    UNION ALL
    SELECT 'mon_dia', mon_dia FROM exam_results
    UNION ALL
    SELECT 'mon_gdcd', mon_gdcd FROM exam_results
    UNION ALL
    SELECT 'mon_ngoaingu', mon_ngoaingu FROM exam_results
) AS scores
GROUP BY subject;
-- tạo bảng điểm 0 các môn
CREATE TABLE IF NOT EXISTS exam_scores_0 (
    subject_name VARCHAR(50) PRIMARY KEY,
    count_0 INT
);
-- tính toán và thêm dữ liệu vào bảng điểm 0 các môn
INSERT INTO exam_scores_0 (subject_name, count_0)
SELECT subject, SUM(CASE WHEN score = 0 THEN 1 ELSE 0 END)
FROM (
    SELECT 'mon_toan' AS subject, mon_toan AS score FROM exam_results
    UNION ALL
    SELECT 'mon_van', mon_van FROM exam_results
    UNION ALL
    SELECT 'mon_ly', mon_ly FROM exam_results
    UNION ALL
    SELECT 'mon_hoa', mon_hoa FROM exam_results
    UNION ALL
    SELECT 'mon_sinh', mon_sinh FROM exam_results
    UNION ALL
    SELECT 'mon_su', mon_su FROM exam_results
    UNION ALL
    SELECT 'mon_dia', mon_dia FROM exam_results
    UNION ALL
    SELECT 'mon_gdcd', mon_gdcd FROM exam_results
    UNION ALL
    SELECT 'mon_ngoaingu', mon_ngoaingu FROM exam_results
) AS scores
GROUP BY subject;