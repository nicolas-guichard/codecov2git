<!--
SPDX-FileCopyrightText: 2025 Mozilla
SPDX-FileContributor: Nicolas Qiu Guichard <nicolas.guichard@kdab.com>

SPDX-License-Identifier: MPL-2.0
-->

# codecov2git

This takes a code-coverage-report.json from the Firefox CI and writes it to a Git repository.

Each directory has an index.json with summary statistics, each file begins with its own statistics on the first line then each line provides the matching line hit count (with an offset of one obviously).

This is an experiment that will potentially be used in Searchfox.
