<?php
$target_dir = "uploads/";
$message = "";

if (isset($_POST["submit"])) {
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }
    
    $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
    
    // Low security: no file extension checking or MIME type validation
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        $message = "<p class='success'>File " . htmlspecialchars(basename($_FILES["fileToUpload"]["name"])) . " has been uploaded successfully to <a href='" . htmlspecialchars($target_file) . "'>" . htmlspecialchars($target_file) . "</a></p>";
    } else {
        $message = "<p class='error'>Sorry, there was an error uploading your file.</p>";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>S.H.I.E.L.D. Command Panel - Uploads</title>
    <style>
        body {
            background-color: #0c0d10;
            color: #ffffff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-image: radial-gradient(circle, #1a1c23 10%, #0c0d10 90%);
        }
        .upload-card {
            background-color: rgba(18, 20, 26, 0.95);
            border: 2px dashed #d12c2c;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 0 25px rgba(209, 44, 44, 0.2);
            border-top: 6px solid #d12c2c;
        }
        h2 {
            margin-bottom: 5px;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .subtitle {
            color: #d12c2c;
            font-size: 0.85em;
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 25px;
            font-weight: bold;
        }
        form {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .file-input-wrapper {
            position: relative;
            margin: 25px 0;
            width: 100%;
        }
        input[type="file"] {
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.03);
            padding: 12px;
            border-radius: 4px;
            width: 90%;
            color: #a0a6b5;
            cursor: pointer;
        }
        input[type="submit"] {
            background-color: #d12c2c;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: all 0.2s ease;
        }
        input[type="submit"]:hover {
            background-color: #ff4d4d;
            box-shadow: 0 0 10px rgba(209, 44, 44, 0.4);
        }
        .success { 
            color: #4cd137; 
            margin-top: 20px; 
            background: rgba(76, 209, 55, 0.1);
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #4cd137;
        }
        .success a {
            color: #ffffff;
            text-decoration: underline;
        }
        .error { 
            color: #ff4d4d; 
            margin-top: 20px; 
            background: rgba(255, 77, 77, 0.1);
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #ff4d4d;
        }
        .footer {
            margin-top: 30px;
            font-size: 0.75em;
            color: #626875;
        }
    </style>
</head>
<body>
    <div class="upload-card">
        <h2>S.H.I.E.L.D.</h2>
        <div class="subtitle">Admin Command Panel</div>
        <form action="" method="post" enctype="multipart/form-data">
            <div class="file-input-wrapper">
                <input type="file" name="fileToUpload" id="fileToUpload" required>
            </div>
            <input type="submit" value="Deploy Module" name="submit">
        </form>
        <?php echo $message; ?>
        <div class="footer">
            SECURE MODULE UPLOAD ENGINE v1.0.4
        </div>
    </div>
</body>
</html>
