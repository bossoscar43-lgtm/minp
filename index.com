<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CryptoMiner - Simulation de Minage</title>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #3b82f6;
            --primary-dark: #1e40af;
            --secondary: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --bg-primary: #0f172a;
            --bg-secondary: #1e293b;
            --bg-tertiary: #334155;
            --text-primary: #f1f5f9;
            --text-secondary: #cbd5e1;
            --border: #475569;
        }

        body {
            background-color: var(--bg-primary);
            color: var(--text-primary);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 1rem;
        }

        header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            padding: 2rem 0;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }

        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1rem;
        }

        .logo {
            font-size: 1.8rem;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .user-section {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-info {
            text-align: right;
        }

        .username {
            font-weight: 600;
        }

        .balance {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        button {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 0.5rem;
            cursor: pointer;
            font-size: 0.95rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background-color: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: var(--bg-tertiary);
            color: var(--text-primary);
        }

        .btn-secondary:hover {
            background-color: var(--border);
        }

        .btn-danger {
            background-color: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background-color: #dc2626;
        }

        .btn-success {
            background-color: var(--secondary);
            color: white;
        }

        .btn-success:hover {
            background-color: #059669;
        }

        .card {
            background-color: var(--bg-secondary);
            border: 1px solid var(--border);
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--text-primary);
        }

        .card-subtitle {
            font-size: 0.9rem;
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .form-group {
            margin-bottom: 1.25rem;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--text-secondary);
        }

        input,
        select {
            width: 100%;
            padding: 0.75rem;
            background-color: var(--bg-tertiary);
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            color: var(--text-primary);
            font-size: 0.95rem;
            transition: border-color 0.3s ease;
        }

        input:focus,
        select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .stat-box {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(16, 185, 129, 0.1) 100%);
            border-left: 4px solid var(--primary);
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
        }

        .stat-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.25rem;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .estimation {
            background-color: var(--bg-tertiary);
            border-left: 4px solid var(--secondary);
            padding: 1rem;
            border-radius: 0.5rem;
            margin: 1rem 0;
        }

        .estimation-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--secondary);
        }

        .estimation-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .contract-item {
            background-color: var(--bg-tertiary);
            border-left: 4px solid var(--primary);
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .contract-info {
            flex: 1;
        }

        .contract-status {
            padding: 0.25rem 0.75rem;
            border-radius: 0.25rem;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            margin-left: 1rem;
        }

        .status-active {
            background-color: rgba(16, 185, 129, 0.2);
            color: var(--secondary);
        }

        .status-completed {
            background-color: rgba(59, 130, 246, 0.2);
            color: var(--primary);
        }

        .auth-container {
            max-width: 400px;
            margin: 2rem auto;
        }

        .hidden {
            display: none;
        }

        .error {
            background-color: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--danger);
            color: #fca5a5;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
        }

        .success {
            background-color: rgba(16, 185, 129, 0.1);
            border: 1px solid var(--secondary);
            color: #86efac;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
        }

        .loading {
            text-align: center;
            padding: 2rem;
        }

        .spinner {
            border: 3px solid var(--bg-tertiary);
            border-top: 3px solid var(--primary);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .tabs {
            display: flex;
            border-bottom: 2px solid var(--border);
            margin-bottom: 1.5rem;
            gap: 0.5rem;
        }

        .tab-button {
            padding: 1rem 1.5rem;
            background: none;
            color: var(--text-secondary);
            border: none;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .tab-button.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .contract-breakdown {
            font-size: 0.9rem;
            color: var(--text-secondary);
            margin-top: 0.5rem;
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }

            .user-section {
                flex-direction: column;
                gap: 0.5rem;
            }

            .user-info {
                text-align: center;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .contract-item {
                flex-direction: column;
                align-items: flex-start;
            }

            .contract-status {
                margin-left: 0;
                margin-top: 0.5rem;
            }

            .tabs {
                overflow-x: auto;
            }

            .tab-button {
                padding: 0.75rem 1rem;
                font-size: 0.9rem;
            }
        }
    </style>
</head>
<body>
    <header id="header" class="hidden">
        <div class="header-content">
            <div class="logo">💰 CryptoMiner</div>
            <div class="user-section">
                <div class="user-info">
                    <div class="username" id="userName">Utilisateur</div>
                    <div class="balance" id="userBalance">Points: 0</div>
                </div>
                <button class="btn-primary" onclick="logout()">Déconnexion</button>
            </div>
        </div>
    </header>

    <div class="container">
        <div id="authSection" class="auth-container">
            <div id="authError" class="error hidden"></div>
            <div id="authSuccess" class="success hidden"></div>

            <div id="loginForm">
                <div class="card">
                    <div class="card-title">🔐 Connexion</div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" id="loginEmail" placeholder="votre@email.com">
                    </div>
                    <div class="form-group">
                        <label>Mot de passe</label>
                        <input type="password" id="loginPassword" placeholder="••••••••">
                    </div>
                    <button class="btn-primary" style="width: 100%; margin-bottom: 1rem;" onclick="login()">Se connecter</button>
                    <p style="text-align: center; margin-bottom: 1rem;">
                        <span style="color: var(--text-secondary);">Pas encore de compte?</span>
                    </p>
                    <button class="btn-secondary" style="width: 100%;" onclick="toggleAuthForm()">Créer un compte</button>
                </div>
            </div>

            <div id="signupForm" class="hidden">
                <div class="card">
                    <div class="card-title">📝 Inscription</div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" id="signupEmail" placeholder="votre@email.com">
                    </div>
                    <div class="form-group">
                        <label>Mot de passe</label>
                        <input type="password" id="signupPassword" placeholder="••••••••">
                    </div>
                    <div class="form-group">
                        <label>Confirmer le mot de passe</label>
                        <input type="password" id="signupPasswordConfirm" placeholder="••••••••">
                    </div>
                    <button class="btn-success" style="width: 100%; margin-bottom: 1rem;" onclick="signup()">S'inscrire</button>
                    <button class="btn-secondary" style="width: 100%;" onclick="toggleAuthForm()">Retour à la connexion</button>
                </div>
            </div>
        </div>

        <div id="appSection" class="hidden">
            <div class="tabs">
                <button class="tab-button active" id="tab-dashboard" onclick="switchTab('dashboard')">📊 Tableau de bord</button>
                <button class="tab-button" id="tab-mining" onclick="switchTab('mining')">⛏️ Créer un contrat</button>
                <button class="tab-button" id="tab-history" onclick="switchTab('history')">📜 Historique</button>
            </div>

            <div id="dashboardTab" class="tab-content active">
                <div class="grid">
                    <div class="card">
                        <div class="card-title">Solde Disponible</div>
                        <div class="stat-box">
                            <div class="stat-label">Points Disponibles</div>
                            <div class="stat-value" id="availableBalance">0</div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-title">Résumé Actifs</div>
                        <div class="stat-box">
                            <div class="stat-label">Contrats en Cours</div>
                            <div class="stat-value" id="activeContractsCount">0</div>
                        </div>
                        <div style="margin-top: 0.5rem; color: var(--text-secondary); font-size: 0.9rem;">
                            Points bloqués: <span id="blockedAmount">0</span>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-title">Rendements Prévus</div>
                        <div class="stat-box">
                            <div class="stat-label">Gains Estimés</div>
                            <div class="stat-value" style="color: var(--secondary);" id="estimatedGains">0</div>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-title">📈 Derniers Contrats Actifs</div>
                    <div id="recentContracts" style="max-height: 300px; overflow-y: auto;">
                        <p style="color: var(--text-secondary); text-align: center; padding: 2rem;">Aucun contrat actif pour le moment</p>
                    </div>
                </div>
            </div>

            <div id="miningTab" class="tab-content">
                <div class="card">
                    <div class="card-title">⛏️ Créer un Nouveau Contrat de Minage</div>
                    <div class="card-subtitle">Choisissez un montant et une durée pour générer des rendements passifs</div>

                    <div class="form-group">
                        <label>Montant à bloquer (points)</label>
                        <input type="number" id="miningAmount" min="10" placeholder="Minimum 10 points" oninput="updateEstimation()">
                        <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 0.25rem;">
                            Solde disponible: <span id="balanceInfo">0</span> points
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Durée du blocage</label>
                        <select id="miningDuration" onchange="updateEstimation()">
                            <option value="">Sélectionner une durée...</option>
                            <option value="7">7 jours - 4% par an</option>
                            <option value="30">30 jours - 6% par an</option>
                            <option value="90">90 jours - 8% par an</option>
                        </select>
                    </div>

                    <div id="estimationContainer"></div>

                    <button class="btn-success" style="width: 100%; padding: 0.75rem; font-size: 1rem;" onclick="createContract()">Créer le Contrat</button>
                </div>
            </div>

            <div id="historyTab" class="tab-content">
                <div class="card">
                    <div class="card-title">📜 Historique des Contrats</div>
                    <div class="card-subtitle" id="contractCountInfo">Tous les contrats passés et en cours</div>

                    <div id="contractList" style="max-height: 600px; overflow-y: auto;">
                        <div class="loading">
                            <div class="spinner"></div>
                            <p>Chargement des contrats...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const SUPABASE_URL = 'https://sfiieececneqeimckbwbjha.supabase.co';
        const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmaWVlY2VjbmVxaW1ja2J3YmhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI2MTc2NzksImV4cCI6MjA5ODE5MzY3OX0.dKukuD20Ku0FKEXwjhL6wgOgpjeMf1KpqNNF4lI6DeM';
        const { createClient } = window.supabase;
        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

        const RATES = { 7: 4, 30: 6, 90: 8 };
        let currentUser = null;
        let currentProfile = null;

        window.addEventListener('load', async () => {
            const { data: { session } } = await supabase.auth.getSession();
            if (session) {
                currentUser = session.user;
                await loadProfile();
                showApp();
            } else {
                showAuth();
            }

            supabase.auth.onAuthStateChange(async (event, session) => {
                if (session) {
                    currentUser = session.user;
                    await loadProfile();
                    showApp();
                } else {
                    currentUser = null;
                    currentProfile = null;
                    showAuth();
                }
            });
        });

        async function login() {
            const email = document.getElementById('loginEmail').value.trim();
            const password = document.getElementById('loginPassword').value;
            if (!email || !password) return showAuthError('Veuillez remplir tous les champs');

            try {
                const { error } = await supabase.auth.signInWithPassword({ email, password });
                if (error) throw error;
                clearAuthError();
            } catch (err) {
                showAuthError(err.message);
            }
        }

        async function signup() {
            const email = document.getElementById('signupEmail').value.trim();
            const password = document.getElementById('signupPassword').value;
            const confirm = document.getElementById('signupPasswordConfirm').value;

            if (!email || !password || !confirm) return showAuthError('Veuillez remplir tous les champs');
            if
