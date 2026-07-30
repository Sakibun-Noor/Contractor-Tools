<?php
/**
 * Tasmio Drive — local user accounts (stored in data/users.json).
 * Site users log in here; they do NOT need a Microsoft/OneDrive account.
 */

class Auth {
    private $file;

    public function __construct() {
        $this->file = __DIR__ . '/../data/users.json';
    }

    private function load() {
        if (!file_exists($this->file)) {
            return ['users' => []];
        }
        $data = json_decode(file_get_contents($this->file), true);
        return is_array($data) ? $data : ['users' => []];
    }

    private function save($data) {
        file_put_contents(
            $this->file,
            json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES),
            LOCK_EX
        );
    }

    public function hasUsers() {
        $data = $this->load();
        return count($data['users']) > 0;
    }

    public function find($username) {
        $username = strtolower(trim($username));
        foreach ($this->load()['users'] as $u) {
            if (strtolower($u['username']) === $username) return $u;
        }
        return null;
    }

    /** Create a user. First user created is always an admin. */
    public function createUser($username, $password, $role = null) {
        $username = trim($username);
        if (!preg_match('/^[A-Za-z0-9_.-]{3,32}$/', $username)) {
            throw new Exception('Username must be 3–32 chars: letters, numbers, . _ -');
        }
        if (strlen($password) < 6) {
            throw new Exception('Password must be at least 6 characters.');
        }
        $data = $this->load();
        if ($this->find($username)) {
            throw new Exception('That username is already taken.');
        }
        if ($role === null) {
            $role = count($data['users']) === 0 ? 'admin' : 'user';
        }
        $data['users'][] = [
            'username'      => $username,
            'password_hash' => password_hash($password, PASSWORD_DEFAULT),
            'role'          => $role,
            'created'       => date('c'),
        ];
        $this->save($data);
        return $this->find($username);
    }

    public function verify($username, $password) {
        $u = $this->find($username);
        if (!$u) return false;
        if (!password_verify($password, $u['password_hash'])) return false;
        return $u;
    }

    public function login($user) {
        start_session();
        session_regenerate_id(true);
        $_SESSION['user'] = [
            'username' => $user['username'],
            'role'     => $user['role'],
        ];
    }

    public function logout() {
        start_session();
        $_SESSION = [];
        session_destroy();
    }

    public function current() {
        start_session();
        return $_SESSION['user'] ?? null;
    }

    public function requireLogin() {
        if (!$this->current()) {
            header('Location: login.php');
            exit;
        }
        return $this->current();
    }

    public function isAdmin() {
        $u = $this->current();
        return $u && $u['role'] === 'admin';
    }

    public function requireAdmin() {
        $this->requireLogin();
        if (!$this->isAdmin()) {
            http_response_code(403);
            exit('Admins only.');
        }
    }

    public function listUsers() {
        return $this->load()['users'];
    }

    public function deleteUser($username) {
        $data = $this->load();
        $data['users'] = array_values(array_filter(
            $data['users'],
            fn($u) => strtolower($u['username']) !== strtolower($username)
        ));
        $this->save($data);
    }

    public function setPassword($username, $password) {
        if (strlen($password) < 6) {
            throw new Exception('Password must be at least 6 characters.');
        }
        $data = $this->load();
        foreach ($data['users'] as &$u) {
            if (strtolower($u['username']) === strtolower($username)) {
                $u['password_hash'] = password_hash($password, PASSWORD_DEFAULT);
                $this->save($data);
                return true;
            }
        }
        return false;
    }
}
