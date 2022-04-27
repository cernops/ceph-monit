#!/usr/bin/env python3
import hashlib
import os
import pathlib

import gitlab
from gitlab.v4.objects.projects import Project


def check_file_status(project: Project):
    """Check if any rule files got updated"""
    commit_actions = []
    files = [pathlib.Path('alerts.yaml'), pathlib.Path('rules.yaml')]
    for file_path in files:
        file_content = file_path.read_bytes()
        # Check if file is up to date on qa
        try:
            file = project.files.get(
                file_path=f"code/files/prometheus/generated_rules/{file_path.name}",
                ref="qa",
            )
            if file.content_sha256 == hashlib.sha256(file_content).hexdigest():
                print(f"{file_path.name} is up to date on qa")
                continue
        except gitlab.exceptions.GitlabGetError:
            print(f"{file_path.name} does not exist on qa, checking on ceph-monit-bot branch")
        try:
            file = project.files.get(
                file_path=f"code/files/prometheus/generated_rules/{file_path.name}",
                ref="ceph-monit-bot",
            )
            if file.content_sha256 == hashlib.sha256(file_content).hexdigest():
                print(f"{file_path.name} is up to date on ceph-monit-bot")
                continue
            else:
                print(f"{file_path.name} is outdated on ceph-monit-bot branch")
                commit_actions.append(
                    {
                        "action": "update",
                        "file_path": f"code/files/prometheus/generated_rules/{file_path.name}",
                        "content": file_content.decode(),
                    }
                )
        except gitlab.exceptions.GitlabGetError:  # File does not exist yet
            print(f"{file_path.name} does not exist on ceph-monit-bot branch")
            commit_actions.append(
                {
                    "action": "create",
                    "file_path": f"code/files/prometheus/generated_rules/{file_path.name}",
                    "content": file_content.decode(),
                }
            )
    return commit_actions


def commit(project: Project, actions: list[dict]):
    """Commit latest changes"""
    data = {
        "branch": "ceph-monit-bot",
        "commit_message": f"Prometheus: update rules from ceph-monit to {os.environ['CI_COMMIT_SHORT_SHA']}",
        "force": False,
        "actions": actions,
    }
    try:
        project.branches.get("ceph-monit-bot")
    except gitlab.exceptions.GitlabGetError:
        print("Creating new branch ceph-monit-bot")
        data["start_branch"] = "qa"

    project.commits.create(data)
    print("Committed changes to ceph-monit-bot")


def create_merge_request(project: Project):
    """If a merge request for ceph-monit-bot by this script does not exist yet, create one"""
    source_branch = "ceph-monit-bot"
    response = project.mergerequests.list(
        scope="created_by_me",
        source_branch=source_branch,
        state="opened",
    )
    if not response:  # Create MR
        data = {
            "source_branch": source_branch,
            "target_branch": "qa",
            "title": f"Prometheus: Update rules from ceph-monit to {os.environ['CI_COMMIT_SHORT_SHA']}",
            "remove_source_branch": True,
            "description": f"This is an automatic commit created from https://gitlab.cern.ch/ceph/ceph-monit to update the Prometheus "
                           f"rules/alerts. \nUsing https://gitlab.cern.ch/ceph/ceph-monit/-/commit/{os.environ['CI_COMMIT_SHORT_SHA']}",
            "should_remove_source_branch": True,
            "merge_when_pipeline_succeeds": True,
        }
        project.mergerequests.create(data)
        print("Merge request created")


def main():
    client = gitlab.Gitlab(url="https://gitlab.cern.ch", private_token=os.environ["CI_ACCESS_TOKEN"])
    project = client.projects.get(os.environ["HG_PROJECT_ID"])

    commit_actions = check_file_status(project)
    if commit_actions:
        commit(project, commit_actions)
        create_merge_request(project)


if __name__ == "__main__":
    main()
