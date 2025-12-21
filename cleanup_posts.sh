#!/bin/bash
set -e

WEBSITE_ROOT="/home/blas/Dropbox/blas/GITHUB/myWebsite"
CLEANUP_DATE=$(date +%Y%m%d-%H%M%S)
TRASH_DIR="${WEBSITE_ROOT}/.cleanup_trash/${CLEANUP_DATE}"

cd "$WEBSITE_ROOT"
mkdir -p "${TRASH_DIR}/02_parallelizing_loops_with_r"

echo "========================================="
echo "Blog Post Cleanup"
echo "========================================="
echo ""
echo "Cleaning post: 02_parallelizing_loops_with_r"
echo ""
echo "Files to move to trash:"
echo "  - parallelized_loops.Rmd"
echo "  - parallelized_loops.md"
echo "  - index.md"
echo ""

read -p "Proceed? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

POST_02="content/post/02_parallelizing_loops_with_r"

mv "${POST_02}/parallelized_loops.Rmd" "${TRASH_DIR}/02_parallelizing_loops_with_r/" && \
    echo "  ✓ Moved parallelized_loops.Rmd"

mv "${POST_02}/parallelized_loops.md" "${TRASH_DIR}/02_parallelizing_loops_with_r/" && \
    echo "  ✓ Moved parallelized_loops.md"

mv "${POST_02}/index.md" "${TRASH_DIR}/02_parallelizing_loops_with_r/" && \
    echo "  ✓ Moved index.md"

echo ""
echo "Cleanup complete!"
echo "Trash: ${TRASH_DIR}"
echo ""
echo "Remaining files:"
ls -lh "${POST_02}/"*.{Rmarkdown,markdown}
