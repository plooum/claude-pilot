---
name: pilot-<project>
description: Spécificités de <Projet> pour le pilote (<Project>'s specifics for the pilot) - environnement de dev, étapes de merge et de release, ajouts à la checklist de relecture, machines. À charger avec le skill `pilot` quand tu es le pilote de <projet> (you are the pilot of <project>).
---

# Pilote de <projet>

Complète le skill global `pilot` avec ce qui est propre à ce projet. Reste court et factuel.

## Environnement de dev

- Démarrer / vérifier / arrêter : `<commandes>`. Vérifie-le au début de la session.
- Par worktree : ce dont un sous-agent a besoin en propre (port, dépendances liées, étape de build), et comment il l'arrête quand il a fini.
- Parallélisme : combien de sous-agents à la fois sur chaque machine, et pourquoi.

## Checklist de relecture (ajouts)

- <élément propre au projet : par ex. docs en deux langues, un fichier de version non incrémenté dans une PR de fonctionnalité, fichiers générés non commités>

## Merge

1. <Règle de rebase : quand `main` a bougé, ce qu'il faut ignorer (par ex. seulement les fichiers du pilote).>
2. <Commande de merge et format du sujet, par ex. `gh pr merge <N> --squash --delete-branch`.>
3. <Ensuite : nettoyer le worktree, arrêter son environnement de dev, vérifier la CI sur `main`.>

## Releases

<Nom des tags et règles semver, qui publie, langue des notes de release, ce que la CI attache.>

## Machines

<Nom : RAM, cœurs, emplacement des outils (`~/.local/bin`...). Reprend la section Machines du handoff.>

## Skills du projet

| Skill | Pour |
| :--- | :--- |
| `<skill de livraison / de test>` | <quand le charger> |
