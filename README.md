# Action pull request another repository 

This GitHub Action copies a folder from the current repository to a location in another repository and create a pull request

## Example Workflow

    name: Push File

    on: push

    jobs:
      docs-pull-request:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2

        - name: Create pull request
          uses: c-commerce/action-pull-request-another-repo@v2.0.0
          env:
            PERSONAL_ACCESS_TOKEN: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          with:
            push_args: '--force'
            source_folder: 'source-folder'
            destination_repo: 'c-commerce/repository-name'
            destination_folder: 'docs/repository-name'
            destination_base_branch: 'develop'
            destination_head_branch: 'feat/docs-${{ github.event.repository.name }}-${{ github.head_ref }}'
            user_email: 'tech@hello-charles.com'
            user_name: 'c-commerce'
            message: 'Docs Update from ${{ github.event.repository.name }}'

## Variables

* source_folder: The folder to be moved. Uses the same syntax as the `cp` command. Incude the path for any files not in the repositories root directory.
* destination_repo: The repository to place the file or directory in.
* destination_folder: [optional] The folder in the destination repository to place the file in, if not the root directory.
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* destination_base_branch: [optional] The branch into which you want your code merged. Default is `main`.
* destination_head_branch: The branch to create to push the changes. Cannot be `master` or `main`.
* pull_request_reviewers: [optional] The pull request reviewers. It can be only one (just like 'reviewer') or many (just like 'reviewer1,reviewer2,...')
* auto_publish: [optional] Whether the newly created pull request should be automatically merged. Default is `false`

## ENV

* API_TOKEN_GITHUB: You must create a personal access token in you account. Follow the link:
- [Personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

> You must select the scopes: 'repo = Full control of private repositories', 'admin:org = read:org' and 'write:discussion = Read:discussion'; 


## Behavior Notes

The action will create any destination paths if they don't exist. It will also overwrite existing files if they already exist in the locations being copied to. It will not delete the entire destination repository.
