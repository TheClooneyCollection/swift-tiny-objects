from pathlib import Path

from invoke import task


@task
def test(c):
    command = "swift test"
    c.run(command)


def plugin_command(plugin):
    return f"swift package plugin --allow-writing-to-package-directory {plugin}"


@task
def format(c):
    root = Path(__file__).parent

    # print(root)

    build = "swift build"
    folders = "Sources Tests"
    swift_lint = plugin_command(f"swiftlint --strict --fix {folders}")
    swift_format = plugin_command(f"swiftformat --swiftversion 6.1.2 {folders}")

    commands = [
            build,
            swift_lint,
            swift_format,
    ]

    # print(commands)

    for command in commands:
        print("> ", command)
        c.run(command)


@task
def lint(c):
    root = Path(__file__).parent

    # print(root)

    build = "swift build"
    folders = "Sources Tests"
    swift_lint = plugin_command(f"swiftlint {folders}")
    swift_format = plugin_command(f"swiftformat --lint --swiftversion 6.1.2 {folders}")

    commands = [
            build,
            swift_lint,
            swift_format,
    ]

    # print(commands)

    for command in commands:
        print("> ", command)
        c.run(command)
