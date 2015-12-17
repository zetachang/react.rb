
For example assuming you are releasing fix to 0.8.18

1. Checkout 0-8-stable
2. Update tests, fix the bug and commit the changes.
3. Build & Release to RubyGems (Remember the version in version.rb should already be 0.8.19)
4. Create a tag 'v0.8.19' pointing to that commit. (`tag v0.8.19`)
5. Bump the version in 0-8-stable to 0.8.20 so it will be ready for the next patch level release.
6. Commit the version bump, and do a `git push --tags` so the new tag goes up
