# AGENTS.md : être le pilote d'un projet

Pour un agent IA à qui on dit « tu es le pilote de ce projet, suis https://github.com/plooum/claude-pilot ». Fais ceci dans l'ordre.

1. **Installer.** Vérifie `ls ~/.claude/skills/pilot ~/.claude/skills/pilot-subagent`. S'ils manquent :
   `git clone https://github.com/plooum/claude-pilot ~/.local/opt/claude-pilot && ~/.local/opt/claude-pilot/install.sh`
   Il relie les deux skills dans `~/.claude/skills` par des liens symboliques (pas de hook, aucun changement de réglages ; idempotent ; il laisse intact tout ce qui s'y trouve déjà). Une nouvelle session peut être nécessaire pour voir les skills : d'ici là, lis directement `~/.local/opt/claude-pilot/skills/pilot/SKILL.md`.
2. **Tableau des agents (recommandé, jamais obligatoire).** Un tableau en direct des sous-agents. Demande à l'utilisateur, puis suis le `AGENTS.md` de https://github.com/plooum/agent-board. Sans lui, le pilote travaille pareil.
3. **Mettre le projet en place**, s'il n'a pas encore de `.claude/pilot/`, à partir de `~/.local/opt/claude-pilot/templates/` :
   - `.claude/pilot/HANDOFF.md`, `BACKLOG.md` et un dossier `prompts/` vide ;
   - les lignes « Pilot mode » et « Git workflow » dans le `CLAUDE.md` du projet (`CLAUDE-pilot-section.md`) ;
   - un skill `pilot-<projet>` dans `.claude/skills/` (`pilot-project-skill.md`) : environnement de dev, étapes de merge, règles de release, checklist de relecture, machines ;
   - un skill de livraison / de test pour les sous-agents si le projet a des tests ou un environnement de dev qui mérite d'être documenté.

   **Demande à l'utilisateur** les décisions que cela suppose, et consigne-les datées dans le handoff : les fichiers du pilote peuvent-ils aller directement sur `main`, sans PR ? Quelle langue pour la conversation avec lui ? Quel modèle pour les sous-agents (Sonnet par défaut) ? Quelle machine et combien de RAM ? Commite la mise en place comme le projet l'autorise (une PR, sauf si le CLAUDE.md dit autrement).
4. **Démarrer.** Charge le skill `pilot` (et `pilot-<projet>`) et lance sa boucle : lis le handoff, vérifie l'état du dépôt, dis à l'utilisateur où en sont les choses.
