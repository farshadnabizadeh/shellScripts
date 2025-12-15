Here is the guide for managing your project in English, formatted in Markdown.

# 🚀 Future Project Management

Since your application is running inside Docker containers, you should not use the PHP or Composer installed on your local Windows/WSL machine. Instead, you will use **Laravel Sail** to interact with the environment.

**Prerequisite:** Always ensure you are inside your project directory before running these commands:
```bash
cd app
```

### 1. Server Control

*   **Start the Server (in background):**
     This starts all containers (Laravel, MySQL, Redis, etc.) in detached mode.
    ```bash
    ./vendor/bin/sail up -d
    ```
    *Access your site at: `http://localhost:8000`*

*   **Stop the Server:**
    This stops and removes the containers.
    ```bash
    ./vendor/bin/sail down
    ```

*   **Restart specific container:**
    If you need to restart just the app (e.g., after config changes in Octane):
    ```bash
    ./vendor/bin/sail restart laravel.test
    ```

### 2. Development Commands

*   **Run Artisan Commands:**
    Instead of `php artisan`, use:
    ```bash
    ./vendor/bin/sail artisan migrate
    ./vendor/bin/sail artisan make:controller UserController
    ```

*   **Composer (PHP Packages):**
    Instead of `composer require`, use:
    ```bash
    ./vendor/bin/sail composer require laravel/breeze
    ```

*   **NPM (Frontend Assets):**
    Instead of `npm install` or `npm run dev`, use:
    ```bash
    ./vendor/bin/sail npm install
    ./vendor/bin/sail npm run dev
    ```

*   **View Logs:**
    To see what is happening in the background (errors, requests):
    ```bash
    ./vendor/bin/sail logs -f
    ```

### 💡 Pro Tip: Create a Shell Alias

Typing `./vendor/bin/sail` every time is tedious. You can create a shortcut so you only have to type `sail`.

1.  Edit your shell configuration:
    ```bash
    nano ~/.bashrc
    ```
2.  Add this line to the very end of the file:
    ```bash
    alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
    ```
3.  Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
4.  Reload the shell:
    ```bash
    source ~/.bashrc
    ```

**Now you can simply run:**
```bash
sail up -d
sail artisan migrate
```