from pathlib import Path


from invoke import task

@task
def test(c):
    command = "swift test"
    c.run(command)

@task
def lint(c):
    root = Path(__file__).parent

    # print(root)

    def plugin_command(plugin):
        return f"swift package plugin --allow-writing-to-package-directory {plugin}"

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
        c.run(command)
        print()
