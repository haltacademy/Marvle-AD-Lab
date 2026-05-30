<?php
/*
Plugin Name: Stark Industries CMS Uploader
Description: Internal tool to upload administrative assets. Warning: Beta version, low security.
Version: 1.0
Author: Tony Stark
*/

add_action('admin_menu', 'wp_stark_uploader_menu');

function wp_stark_uploader_menu(){
    add_menu_page('Stark Uploader', 'Stark Uploader', 'read', 'wp-stark-uploader', 'wp_stark_uploader_page');
}

function wp_stark_uploader_page(){
    echo '<div class="wrap"><h1>Stark Industries Asset Upload Panel</h1>';
    
    if(isset($_FILES['stark_file'])){
        $upload_dir = wp_upload_dir();
        $target_file = $upload_dir['path'] . '/' . basename($_FILES['stark_file']['name']);
        
        if(move_uploaded_file($_FILES['stark_file']['tmp_name'], $target_file)){
            $file_url = $upload_dir['url'] . '/' . basename($_FILES['stark_file']['name']);
            echo '<div class="notice notice-success is-dismissible"><p>File uploaded successfully! Path: <code>' . esc_html($target_file) . '</code><br>Access URL: <a href="' . esc_url($file_url) . '" target="_blank">' . esc_html($file_url) . '</a></p></div>';
        } else {
            echo '<div class="notice notice-error is-dismissible"><p>Error uploading file.</p></div>';
        }
    }
    
    echo '<form method="post" enctype="multipart/form-data">
        <input type="file" name="stark_file" required>
        <input type="submit" class="button button-primary" value="Upload Asset">
    </form></div>';
}

// Register public unauthenticated AJAX endpoint to simulate a vulnerability (MailPoet-style AFU)
add_action('wp_ajax_nopriv_stark_upload', 'wp_stark_ajax_upload');
add_action('wp_ajax_stark_upload', 'wp_stark_ajax_upload');

function wp_stark_ajax_upload() {
    if (isset($_FILES['file'])) {
        $upload_dir = wp_upload_dir();
        $target_file = $upload_dir['path'] . '/' . basename($_FILES['file']['name']);
        if (move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
            $file_url = $upload_dir['url'] . '/' . basename($_FILES['file']['name']);
            wp_send_json_success(array('url' => $file_url));
        } else {
            wp_send_json_error('Upload failed');
        }
    }
    wp_die();
}
?>
