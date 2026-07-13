**Language / Ngôn ngữ:** [English](CONTRIBUTING_en.md) | [Tiếng Việt](CONTRIBUTING.md)

# Contributing to the Hands-on Network Lab Series

This series is open source under the MIT License (see [LICENSE](../LICENSE)). Community contributions of all kinds are welcome!

## How to Contribute

### Reporting Issues in Existing Labs
Open an issue describing:
- Lab ID (`NN-slug`)
- Issue details (topology failure to deploy, specification errors, skeleton config issues...)
- Command outputs and logs if applicable.

### Proposing New Labs
Open an issue or Pull Request outlining:
- Topic idea & target Arc (see Arc overview in [README_en.md](./README_en.md))
- Target difficulty level
- Labs should be deployable via Containerlab without requiring physical hardware dependencies.

### Submitting Alternative Solutions
**Please submit solutions only after official `loi-giai.md` files have been published** — this prevents spoiling solutions for active learners. PRs can add `loi-giai-cong-dong-<your-name>.md` inside the relevant lab directory, explaining alternative technical approaches.

### Lab Submission Standards (Adding a New Week)
Use [`_template/`](./_template/) as your starting point. Each lab resides in `bai-tap-ve-nha/NN-slug/` and includes:
- `lab-guide.md` (Vietnamese guide) & `lab-guide_en.md` (English guide) — Objectives, Prerequisites, Topology Diagram, Unsolved Lab Tasks, Submission/Verification.
- `topology/*.clab.yml` — Topology definition (3–6 nodes, prioritizing standard images like `quay.io/frrouting/frr` or `wbitt/network-multitool`).
- `configs/` — Baseline skeleton configurations (if needed).
- Update lab catalog tables in `bai-tap-ve-nha/README.md` and `bai-tap-ve-nha/README_en.md`.

Do not include `loi-giai.md` in the initial lab PR — reference solutions are added after the submission deadline (~1 week).
