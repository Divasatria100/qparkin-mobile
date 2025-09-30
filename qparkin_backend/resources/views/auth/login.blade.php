<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    animation: {
                        'fade-in': 'fadeIn 1s ease-in-out',
                        'slide-in': 'slideIn 0.8s ease-out',
                        'bounce-gentle': 'bounceGentle 2s ease-in-out infinite',
                        'pulse-slow': 'pulse 3s ease-in-out infinite',
                        'float': 'float 3s ease-in-out infinite',
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': {
                                opacity: '0',
                                transform: 'translateY(20px)'
                            },
                            '100%': {
                                opacity: '1',
                                transform: 'translateY(0)'
                            }
                        },
                        slideIn: {
                            '0%': {
                                transform: 'translateX(-100%)'
                            },
                            '100%': {
                                transform: 'translateX(0)'
                            }
                        },
                        bounceGentle: {
                            '0%, 100%': {
                                transform: 'translateY(0)'
                            },
                            '50%': {
                                transform: 'translateY(-10px)'
                            }
                        },
                        float: {
                            '0%, 100%': {
                                transform: 'translateY(0px) rotate(0deg)'
                            },
                            '33%': {
                                transform: 'translateY(-10px) rotate(1deg)'
                            },
                            '66%': {
                                transform: 'translateY(5px) rotate(-1deg)'
                            }
                        }
                    }
                }
            }
        }
    </script>
    <style>
        /* Custom gradient background */
        .bg-gradient-animated {
            background: linear-gradient(-45deg, #667eea, #573ED1, #42CBF8, #39108A);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
        }

        @keyframes gradientShift {
            0% {
                background-position: 0% 50%;
            }

            50% {
                background-position: 100% 50%;
            }

            100% {
                background-position: 0% 50%;
            }
        }

        /* Glass morphism effect */
        .glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* Floating elements */
        .floating-element {
            position: absolute;
            opacity: 0.1;
            pointer-events: none;
        }
    </style>
</head>

<body class="bg-gradient-animated min-h-screen flex items-center justify-center relative overflow-hidden">

    <!-- Floating background elements -->
    <div class="floating-element w-64 h-64 bg-white rounded-full top-10 left-10 animate-float"></div>
    <div class="floating-element w-32 h-32 bg-purple-300 rounded-full top-1/2 right-20 animate-pulse-slow"
        style="animation-delay: 1s;"></div>
    <div class="floating-element w-48 h-48 bg-blue-300 rounded-full bottom-20 left-1/3 animate-bounce-gentle"
        style="animation-delay: 2s;"></div>

    <!-- Main login container - Horizontal Layout -->
    <div class="glass rounded-3xl shadow-2xl w-full max-w-5xl mx-4 animate-fade-in relative z-10 overflow-hidden">
        <div class="login-container grid grid-cols-1 md:grid-cols-2 min-h-[600px]">

            <!-- Left Panel - Branding & Welcome -->
            <div class="left-panel flex flex-col items-center justify-center p-8 md:p-12 text-white relative z-10">
                <div class="text-center max-w-md">
                    <!-- Logo -->
                    <div class="w-32 h-32 md:w-40 md:h-40 rounded-full overflow-hidden mx-auto mb-8 animate-bounce-gentle shadow-2xl border-4 border-white/30 logo-container transition-all duration-300 bg-white/10 backdrop-blur-sm">
                        <img src="images/qparkin.png" 
                             alt="QParkIn Logo" 
                             class="w-full h-full object-cover"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                             onload="this.style.opacity='1';"
                             style="opacity:0; transition: opacity 0.5s;">
                        
                        <!-- Fallback logo -->
                        <div class="w-full h-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold text-4xl md:text-5xl" style="display:none;">
                            Q
                        </div>
                    </div>

                    <!-- Welcome Text -->
                    <h1 class="text-4xl md:text-5xl font-bold mb-4 animate-slide-in drop-shadow-lg">QParkin</h1>
                    <p class="text-xl md:text-2xl mb-6 text-blue-100 animate-slide-in" style="animation-delay: 0.2s;">Smart Parking Management</p>
                    <div class="w-20 h-1 bg-white/50 mx-auto mb-6 animate-slide-in" style="animation-delay: 0.4s;"></div>
                    <p class="text-lg text-blue-100/80 leading-relaxed animate-slide-in" style="animation-delay: 0.6s;">
                        Solusi parkir modern dengan teknologi terdepan untuk kemudahan dan efisiensi maksimal
                    </p>

                    <!-- Features -->
                    <div class="mt-8 space-y-3 animate-slide-in" style="animation-delay: 0.8s;">
                        <div class="flex items-center justify-center text-blue-100">
                            <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                            </svg>
                            <span>Real-time Monitoring</span>
                        </div>
                        <div class="flex items-center justify-center text-blue-100">
                            <svg class="w-5 h-5 mr-3" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                            </svg>
                            <span>Smart Analytics</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Panel - Login Form -->
            <div class="right-panel backdrop-blur-sm p-8 md:p-12 flex flex-col justify-center">
                <div class="max-w-md mx-auto w-full">
                    
                    <!-- Form Header -->
                    <div class="text-center mb-8">
                        <h2 class="text-3xl font-bold text-white mb-2 animate-slide-in-right">Selamat Datang</h2>
                        <p class="text-white animate-slide-in-right" style="animation-delay: 0.2s;">Masuk ke panel administrator QParkin</p>
                        <div class="w-16 h-1 bg-gradient-to-r from-blue-500 to-purple-600 mx-auto mt-4 animate-slide-in-right" style="animation-delay: 0.4s;"></div>
                    </div>

            <!-- Error messages with animation -->
            <div id="errorContainer" class="hidden">
                <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-lg mb-6 animate-fade-in">
                    <div class="flex items-center">
                        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd"
                                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                                clip-rule="evenodd" />
                        </svg>
                        <ul id="errorList"></ul>
                    </div>
                </div>
            </div>

            @if ($errors->any())
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
            

            <form id="loginFormSection" method="POST" action="{{ route('login') }}" class="transition-all duration-300">
                @csrf
                <!-- Username field -->
                <div class="relative">
                    <label for="nama"
                        class="block text-white text-sm font-semibold mb-2 transition-colors group-focus-within:text-blue-600">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                            </svg>
                            Nama Pengguna
                        </span>
                    </label>
                    <input type="text" id="name" name="name" required
                        class="w-full px-4 py-3 border border-white rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 hover:border-blue-300 bg-white/80 backdrop-blur-sm"
                        placeholder="Masukkan nama pengguna" autocomplete="username">
                </div>

                <!-- Password field -->
                <div class="mt-6 relative">
                    <label for="password" class="block text-white text-sm font-bold mb-2">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                            </svg>
                            Password
                        </span>
                    </label>
                    <div class="relative">
                        <input type="password" id="password" name="password" required
                            class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 hover:border-blue-300 bg-white/80 backdrop-blur-sm pr-12"
                            placeholder="Masukkan password">
                        <button type="button" id="togglePassword" class="absolute inset-y-0 right-3 flex items-center">
                            <svg id="eyeIcon" class="w-5 h-5 text-gray-400 hover:text-blue-500 transition-colors"
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Submit button -->
                <div class="pt-4">
                    <button type="submit" id="loginBtn"
                        class="w-full bg-gradient-to-r bg-white/10 text-white font-bold py-4 px-6 rounded-xl transition-all duration-300 transform hover:scale-105 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 group">
                        <span class="flex items-center justify-center">
                            <span id="loginText">Login</span>
                            <svg id="loginIcon" class="w-5 h-5 ml-2 transition-transform group-hover:translate-x-1"
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                            </svg>
                            <svg id="loadingIcon" class="w-5 h-5 ml-2 animate-spin hidden" fill="none"
                                viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10"
                                    stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor"
                                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                </path>
                            </svg>
                        </span>
                    </button>
                </div>
            </form>

            <!-- Request Account Form (Hidden by default) -->
            <form id="requestFormSection" method="POST" action="{{ route('register') }}" class="hidden transition-all duration-300">
                @csrf
                <div class="text-center mb-6">
                    <h2 class="text-2xl font-semibold text-white">Ajukan Akun</h2>
                    <p class="text-white mt-1">Isi data berikut untuk mengajukan akun baru.</p>
                </div>

                <div>
                    <label for="req_name" class="block text-sm font-medium text-white mb-1">Nama Lengkap</label>
                    <input id="req_name" name="name" type="text" required class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="Masukkan nama lengkap">
                </div>
                <div class="mt-4">
                    <label for="req_email" class="block text-sm font-medium text-white mb-1">Email</label>
                    <input id="req_email" name="email" type="email" required class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="nama@perusahaan.com">
                </div>
                <div class="mt-4">
                    <label for="req_mall" class="block text-sm font-medium text-white mb-1">Mall</label>
                    <input id="req_mall" name="mall" type="mall" required class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="Minimal 8 karakter">
                </div>

                <div class="pt-4 flex items-center gap-3">
                    <button type="submit" class="w-full bg-gradient-to-r bg-white/10 text-white font-bold py-4 px-6 rounded-xl transition-all duration-300 transform hover:scale-105 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 group">Kirim Pengajuan</button>
                   
                </div>
                <div class="mt-8 text-center animate-slide-in-right" style="animation-delay: 1.4s;" id="switchToLoginContainer">
                    <p class="text-white text-sm">Sudah punya akun? 
                        <a href="#" id="backToLogin" class="text-blue-600 hover:text-blue-500 font-semibold transition-colors">Masuk di sini</a>
                    </p>
                </div>
            </form>
            <!-- Additional links -->
                    <div class="mt-8 text-center animate-slide-in-right" style="animation-delay: 1.4s;" id="switchToRequestContainer">
                        <p class="text-white text-sm">Belum punya akun? 
                            <a href="#" id="openRequestForm" class="text-blue-600 hover:text-blue-500 font-semibold transition-colors">Ajukan di sini</a>
                        </p>
                    </div>
            
            
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="glass rounded-b-3xl p-4 text-center border-t border-white/10 mt-auto">
            <p class="text-white/70 text-sm">
                &copy; 2025 QParkin. Solusi Parkir Terbaik.
            </p>
        </div>

        <script>
            // Toggle password visibility
            document.getElementById('togglePassword').addEventListener('click', function() {
                const passwordField = document.getElementById('password');
                const eyeIcon = document.getElementById('eyeIcon');

                if (passwordField.type === 'password') {
                    passwordField.type = 'text';
                    eyeIcon.innerHTML = `
                    <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd"/>
                    <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z"/>
                `;
                } else {
                    passwordField.type = 'password';
                    eyeIcon.innerHTML = `
                    <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
                    <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
                `;
                }
            });

            // Switch between Login and Request forms
            const openRequestFormBtn = document.getElementById('openRequestForm');
            const backToLoginBtn = document.getElementById('backToLogin');
            const loginFormSection = document.getElementById('loginFormSection');
            const requestFormSection = document.getElementById('requestFormSection');
            const switchToRequestContainer = document.getElementById('switchToRequestContainer');

            function showRequestForm(e) {
                if (e) e.preventDefault();
                loginFormSection.classList.add('hidden');
                requestFormSection.classList.remove('hidden');
                if (switchToRequestContainer) switchToRequestContainer.classList.add('hidden');
            }

            function showLoginForm(e) {
                if (e) e.preventDefault();
                requestFormSection.classList.add('hidden');
                loginFormSection.classList.remove('hidden');
                if (switchToRequestContainer) switchToRequestContainer.classList.remove('hidden');
            }

            openRequestFormBtn && openRequestFormBtn.addEventListener('click', showRequestForm);
            backToLoginBtn && backToLoginBtn.addEventListener('click', showLoginForm);
        </script>
</body>
</html>