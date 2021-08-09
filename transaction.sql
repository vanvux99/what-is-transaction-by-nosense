USE test
GO

CREATE TABLE KhachHang (ID INT IDENTITY(1, 1) PRIMARY KEY, Names NVARCHAR(MAX), TaiKhoanID INT);
GO

CREATE TABLE TaiKhoan (ID INT IDENTITY(1, 1) PRIMARY KEY, Moneys MONEY);
GO

INSERT INTO dbo.TaiKhoan(Moneys)
VALUES(10 -- Moneys - money
    );
GO 
INSERT INTO dbo.KhachHang(Names, TaiKhoanID)
VALUES(N'DOAN VAN VU', -- Names - nvarchar(max)
1   -- TaiKhoanID - int
    ),
    (N'NGUYEN DINH CHIEN', -- Names - nvarchar(max)
2   -- TaiKhoanID - int
    );
GO 
    
SELECT *
FROM dbo.KhachHang kh
     INNER JOIN dbo.TaiKhoan tk ON kh.TaiKhoanID=tk.ID;
GO 

-- chuyển tiền từ chiến sang cho vũ, 10 đồng.

-- 1, trừ đi 10 đồng của chiến -> proc trừ tiền
-- 2, cộng cho vũ 10 đồng -> proc cộng tiền
BEGIN TRY
    BEGIN TRANSACTION GiaoDichChuyenTien;
    BEGIN
    DECLARE @SoTien MONEY=100000;
    --SAVE TRANSACTION GuiTien;
    EXEC Proc_TruTienTaiKhoanNguoiGui 2, @SoTien;
    SAVE TRANSACTION NhanTien;
    EXEC Proc_CongTienTaiKhoanNguoiNhan 1, @SoTien;

    --ROLLBACK TRANSACTION GuiTien;
    --SELECT N'ROLLBACK GuiTien' 

    -- SELECT N'Đã gửi nhận';
    END;
    COMMIT TRANSACTION GiaoDichChuyenTien;
END TRY
BEGIN CATCH
    IF @@ROWCOUNT>1 BEGIN
SELECT N'Transaction lỗi'
    END
END CATCH
GO

ALTER PROCEDURE Proc_TruTienTaiKhoanNguoiGui(@NguoiGuiID AS INT, @SoTienGuiDi MONEY)
AS BEGIN
    DECLARE @TienTrongTaiKhoan MONEY=(SELECT tk.Moneys
                                      FROM dbo.KhachHang kh
                                           INNER JOIN dbo.TaiKhoan tk ON kh.TaiKhoanID=tk.ID AND kh.ID=@NguoiGuiID);
    IF @TienTrongTaiKhoan>@SoTienGuiDi BEGIN
        UPDATE dbo.TaiKhoan
        SET Moneys=Moneys-@SoTienGuiDi
        WHERE dbo.TaiKhoan.ID=(SELECT TaiKhoanID
                               FROM dbo.KhachHang
                               WHERE TaiKhoanID=dbo.TaiKhoan.ID AND dbo.KhachHang.ID=@NguoiGuiID);
        SELECT N'Đã trừ tiền của tài khoản có Tên: '+(SELECT Names FROM dbo.KhachHang WHERE ID=@NguoiGuiID)+'';
    END;
    ELSE SELECT 'False'
END;
GO

CREATE PROCEDURE Proc_CongTienTaiKhoanNguoiNhan(@NguoiGuiID INT, @NguoiNhanID AS INT, @SoTienNhanVe MONEY)
AS BEGIN
    DECLARE @TienTrongTaiKhoan MONEY=(SELECT tk.Moneys
                                      FROM dbo.KhachHang kh
                                           INNER JOIN dbo.TaiKhoan tk ON kh.TaiKhoanID=tk.ID AND kh.ID=@NguoiGuiID);
    IF @TienTrongTaiKhoan>0 BEGIN
        UPDATE dbo.TaiKhoan
        SET Moneys=Moneys+@SoTienNhanVe
        WHERE dbo.TaiKhoan.ID=(SELECT TaiKhoanID
                               FROM dbo.KhachHang
                               WHERE TaiKhoanID=dbo.TaiKhoan.ID AND dbo.KhachHang.ID=@NguoiNhanID);
        SELECT N'Đã cộng tiền vào tài khoản có Tên: '+(SELECT Names FROM dbo.KhachHang WHERE ID=@NguoiNhanID)+'';
    END
    ELSE SELECT 'False'
END;
GO
