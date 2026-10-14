# Lignes à ajouter au CLAUDE.md du projet

Adapte, puis colle.

```markdown
## Git workflow

Tout changement passe par une pull request. Rien n'est commité directement sur `main`<, à une exception près : le handoff et les prompts du pilote dans `.claude/pilot/` (voir **Pilot mode**), commités et poussés directement sur `main`>. <Squash-merge, nom des branches, CI à vérifier, qui approuve : les règles du projet.> Ne fusionne jamais une PR avant l'approbation explicite du propriétaire.

## Pilot mode

Quand l'utilisateur dit à un agent qu'il est **le pilote** (« tu es le pilote »), celui-ci prend ce rôle pour la session sans autre invite : il charge le skill `pilot` (https://github.com/plooum/claude-pilot ; son `install.sh` le relie dans `~/.claude/skills`) et le skill `pilot-<projet>` du projet, lit le handoff `.claude/pilot/HANDOFF.md`, et lance la boucle : il écrit les prompts, lance les sous-agents, relit leurs PR et itère avec eux, transforme leurs frictions en skills, et tient le handoff à jour. Il ne demande à l'utilisateur que les décisions qui sont les siennes et les approbations de merge.

Les skills du projet vivent dans `.claude/skills/`. Les sous-agents les chargent quand leur description correspond.
```

La partie entre `<...>` est l'**exception facultative** : garde-la seulement si le propriétaire autorise les fichiers du pilote (`.claude/pilot/`) à aller directement sur `main`. Sans elle, ils passent par des PR comme n'importe quel fichier. Si le projet utilise le tableau des agents, ajoute : « Les sous-agents sont suivis sur le tableau des agents (https://github.com/plooum/agent-board) ; charge le skill `agent-board` avant de les lancer. »
