<?php

// config/admin.php
//
// Kredensial satu akun Admin/Kasir. Diambil dari .env supaya
// tidak ikut ter-commit ke git (jangan hardcode di sini).

return [
    'username' => env('ADMIN_USERNAME', 'admin'),
    'password' => env('ADMIN_PASSWORD', 'admin123'),
];