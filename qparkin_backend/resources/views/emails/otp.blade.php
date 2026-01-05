<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode OTP QParkin</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .header {
            background: linear-gradient(135deg, #573ED1 0%, #7C3AED 100%);
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 28px;
        }
        .content {
            padding: 40px 30px;
        }
        .greeting {
            font-size: 18px;
            color: #333333;
            margin-bottom: 20px;
        }
        .message {
            font-size: 16px;
            color: #666666;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .otp-box {
            background-color: #f8f9fa;
            border: 2px dashed #573ED1;
            border-radius: 8px;
            padding: 25px;
            text-align: center;
            margin: 30px 0;
        }
        .otp-label {
            font-size: 14px;
            color: #666666;
            margin-bottom: 10px;
        }
        .otp-code {
            font-size: 36px;
            font-weight: bold;
            color: #573ED1;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }
        .warning {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            font-size: 14px;
            color: #856404;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px 30px;
            text-align: center;
            font-size: 14px;
            color: #999999;
        }
        .info-box {
            background-color: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            font-size: 14px;
            color: #0c5460;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🅿️ QParkin</h1>
        </div>
        
        <div class="content">
            <div class="greeting">
                Halo, <strong>{{ $nama }}</strong>!
            </div>
            
            <div class="message">
                Terima kasih telah mendaftar di <strong>QParkin</strong>. Untuk menyelesaikan proses registrasi, 
                silakan gunakan kode OTP berikut:
            </div>
            
            <div class="otp-box">
                <div class="otp-label">Kode OTP Anda:</div>
                <div class="otp-code">{{ $otpCode }}</div>
            </div>
            
            <div class="info-box">
                <strong>📱 Nomor HP:</strong> {{ $nomorHp }}<br>
                <strong>⏰ Berlaku selama:</strong> 5 menit
            </div>
            
            <div class="warning">
                <strong>⚠️ Perhatian:</strong><br>
                • Jangan bagikan kode OTP ini kepada siapapun<br>
                • Kode ini hanya berlaku untuk 1 kali verifikasi<br>
                • Kode akan kedaluwarsa dalam 5 menit
            </div>
            
            <div class="message">
                Jika Anda tidak melakukan registrasi, abaikan email ini.
            </div>
        </div>
        
        <div class="footer">
            <p>Email ini dikirim secara otomatis, mohon tidak membalas.</p>
            <p>&copy; {{ date('Y') }} QParkin. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
