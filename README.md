# \# 🏥 WellCare Pharmacy Management System

# 

# \[!\[Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)

# \[!\[Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

# \[!\[Firebase](https://img.shields.io/badge/Firebase-10.0+-orange.svg)](https://firebase.google.com)

# \[!\[License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

# \[!\[Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-lightgrey.svg)]()

# 

# > A professional, production-ready Pharmacy Management System built with Flutter. Complete solution for medicine inventory, sales, billing, customer management, and reporting.

# 

# \## 📱 Screenshots

# 

# | Login Screen | Dashboard | Medicines |

# |--------------|-----------|-----------|

# | !\[Login](screenshots/login.png) | !\[Dashboard](screenshots/dashboard.png) | !\[Medicines](screenshots/medicines.png) |

# 

# | Sales/Cart | Reports | Profile |

# |------------|---------|---------|

# | !\[Sales](screenshots/sales.png) | !\[Reports](screenshots/reports.png) | !\[Profile](screenshots/profile.png) |

# 

# \## ✨ Features

# 

# \### Core Features

# | Feature | Description |

# |---------|-------------|

# | 🏠 \*\*Dashboard\*\* | Real-time statistics and activity overview |

# | 💊 \*\*Medicine Management\*\* | Add, Edit, Delete medicines with stock tracking |

# | 🛒 \*\*Sales \& Billing\*\* | Complete cart system with tax calculation (5%) |

# | 📄 \*\*Invoice Generation\*\* | Professional PDF invoices |

# | 👥 \*\*Customer Management\*\* | Add, Edit, Delete customers with purchase history |

# | 🏢 \*\*Supplier Management\*\* | Add, Edit, Delete suppliers with due tracking |

# | 💰 \*\*Expense Tracking\*\* | Track daily expenses with category filtering |

# | 📊 \*\*Reports\*\* | PDF reports (Daily/Monthly/Yearly) + Excel export |

# | ⚠️ \*\*Stock Alerts\*\* | Low stock and expiry notifications |

# | 🌙 \*\*Dark Mode\*\* | Toggle between light and dark themes |

# | 🌐 \*\*Multi-Language\*\* | English \& Pashto (پښتو) support |

# | 👤 \*\*Profile Picture\*\* | Upload and save profile picture from PC |

# 

# \### Technical Features

# | Feature | Description |

# |---------|-------------|

# | 🔐 \*\*Firebase Authentication\*\* | Email/Password login with secure authentication |

# | 💾 \*\*Firebase Realtime Database\*\* | Cloud-based data storage with real-time sync |

# | 🔒 \*\*Encryption\*\* | AES encryption for sensitive data |

# | 📢 \*\*Notifications\*\* | Local and push notifications for alerts |

# | ⏰ \*\*Background Services\*\* | Automated stock checks and daily reports |

# | 🎨 \*\*Provider State Management\*\* | Clean and scalable architecture |

# | 📊 \*\*Performance Profiling\*\* | App performance monitoring and logging |

# | 🌐 \*\*REST API Integration\*\* | External API for exchange rates |

# | 🔄 \*\*Alternative Backend\*\* | Fallback API support for reliability |

# 

# \## 🏗️ Architecture

lib/

├── main.dart # Application entry point

├── screens/ # 17+ UI screens

│ ├── splash\_screen.dart

│ ├── login\_screen.dart

│ ├── dashboard\_screen.dart

│ ├── medicines\_screen.dart

│ ├── sales\_screen.dart

│ ├── cart\_screen.dart

│ ├── customers\_screen.dart

│ ├── suppliers\_screen.dart

│ ├── expenses\_screen.dart

│ ├── reports\_screen.dart

│ ├── stock\_alerts\_screen.dart

│ └── profile\_screen.dart

├── providers/ # State management

│ ├── theme\_provider.dart

│ └── language\_provider.dart

├── services/ # Service layer

│ ├── encryption\_service.dart

│ ├── notification\_service.dart

│ ├── ads\_service.dart

│ ├── background\_service.dart

│ ├── permission\_service.dart

│ ├── api\_service.dart

│ └── performance\_service.dart

└── models/ # Data models



\## 🚀 Getting Started



\### Prerequisites



\- \*\*Flutter SDK\*\* 3.0 or higher

\- \*\*Dart SDK\*\* 3.0 or higher

\- \*\*Android Studio\*\* / \*\*VS Code\*\* (with Flutter extensions)

\- \*\*Git\*\* (for version control)



\### Installation



1\. \*\*Clone the repository\*\*

```bash

git clone https://github.com/2021se48-collab/wellcare-pharmacy-system.git

cd wellcare-pharmacy-system


