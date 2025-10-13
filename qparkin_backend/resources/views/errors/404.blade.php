<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Layanan Tidak Tersedia - QParkIn</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
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
    <div class="floating-element w-64 h-64 bg-white rounded-full top-20 left-30 animate-float"></div>
    <div class="floating-element w-32 h-32 bg-purple-300 rounded-full top-1/2 right-20 animate-pulse-slow"
        style="animation-delay: 1s;"></div>
    <div class="floating-element w-48 h-48 bg-blue-300 rounded-full bottom-20 left-10 animate-bounce-gentle"
        style="animation-delay: 2s;"></div>
    <div class="p-8 text-center max-w-md">
    <h1 class="text-7xl text-white font-bold mb-4">503
    <h2 class="text-3xl text-white font-semibold mb-4">Layanan Tidak Tersedia</h1>
        <p class="text-gray-200 mb-6">Sistem sedang dalam pemeliharaan. Silakan coba lagi nanti.</p>
        <div class="bg-gradient-to-r p-4 rounded mb-4">
            <p class="text-gray-200 mb-6">Perkiraan waktu selesai: 30 menit</p>
        </div>
        <a href="{{ url('/') }}"
            class="bg-gradient-to-r bg-white/30 hover:bg-blue-700 text-white font-bold py-3 px-5 rounded-xl">
            Refresh Halaman
        </a>
        </div>
</body>
</html>
