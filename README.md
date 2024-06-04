# Butter Snap
A Bash script to create and maintain the history of snapshots of Btrfs (sub)volumes.

> Butter is from the "Btr" string in name "Btrfs", despite that it's actually "B-tree FS", not "Butter FS". Snap is for snapshot.

Features:
- Able to specify the path to store the snapshots.
  - Can be inside or outside the target.
- Able to purge old snapshots when too many exist.
- Able to keep multiple snapshot schedules for the same target.
- Designed to be called from cron on a regular schedule.

## Requirements
- System: normally a GNU/Linux Distro.
- Dependencies:
  - Bash.
  - btrfs-progs, which provides `btrfs` command.

## Install
- AUR: `yay -S --needed --noconfirm butter-snap-git`
- Manually: Clone the repo, copy `buttersnap` to `/usr/local/bin/` (or elsewhere included in `$PATH`) and ensure it has executing permission.

## Basic usage
Syntax:
```bash
# Options can be placed before target.
buttersnap <target> [options]
```
The command above creates a snapshot of `<target>` as `<store path>/<snapname>`.
- `<target>`: The path or mountpoint of a Btrfs (sub)volume.
  - Internally it will be read as `target=$(realpath -m <target>)`.

> Example: `buttersnap / -n"hourly"` will make a snapshot in `/.snapshots` with a name `hourly_<date>_<time>`.
> - `<date>` is on the form `YYYY-MM-DD`,
> - `<time>` is on the form `HH:MM:SS`,
> - The 5 newest snapshots matching the prefix `hourly_` are kept around; the rest are deleted.


**Options for `<store path>`:**
- `-s`, `--store-dir <store directory>`: Specify the value for `<store directory>` (by default `.snapshots`).
- `-S`, `--store-pathtype <store pathtype>`: Specify the value for `<store pathtype>` (by default `rel`).
  - `rel` (relative): Let `<store path>` to be `<target (in realpath)>/<store directory>`.
  - `mim` (mimic):    Let `<store path>` to be `<store directory>/<target (in realpath)>`.
  - `abs` (absolute): Let `<store path>` to be `<store directory>`.
    - In this case, choose `<snapname adj>` wisely to avoid name conflicts.

**Options for `<snapname>`:**
- `-n`, `--snapname-adj <snapname adj>`: To be used in the name of the snapshot, by default as prefix. The default value is `snapshot`.
  - It's recommended to set this value corresponding to the schedule, such as `hourly`, `daily`, `weekly` or `1m`, `3h`, `1d`, `1w`, `3mo`.
- `-N`,`--snapname-type <snapname type>`: Select a set of snapname and matching pattern. By default `default`.
  - `default`: Snapname in form of `<snapname adj>_%Y-%m-%d_%H:%M:%S`, with corresponding matching pattern.
    - Applicable snapname option(s): `compatible`, `postfix`.
  - `vfs`: Use the Samba `vfs_shadow_copy` snapshot naming convention. Snapname in form of `@GMT-%Y.%m.%d-%H.%M.%S`, with corresponding matching pattern.
  - `custom`: Custom snapname and matching pattern.
    - `--snapname-value <snapname>`: Specify customed snapname.
    - `--snapname-pattern <snapname pattern>`: Specify customed pattern to match the snapname.
- `-o`,`--snapname-ops <snapname options>`: Additional options for a snapname type. By default none.
  - Only apply when applicable.
  - Multiple options should be split by `,`, e.g. `compatible,postfix`.
  - `compatible`: Compatible snapshot names (i.e. no colons that confuse SAMBA/Windows clients).
  - `postfix`: Use `<snapname adj>` as postfix instead of prefix. Might be usefull for chronological sorting.

**Options for creating behavior:**
- `-t`, `--time <time>`: A snapshot will be created **only** if the newest already existing snapshot is older than `<time>` in seconds.
  - Unless `-T` is specified, no snapshot will be made if `<target>` has identical timestamp as the newest snapshot. The modification timestamps of the subvolumes/folders are used for comparison which **might not** work in some scenarios.
- `-T`, `--use-transid`: When `-t` is specified, no snapshot will be made if `<target>` has a lower or equal transition-id than newest snapshot.
- `-r`, `--readonly`: Create the snapshot as readonly (requires btrfs-tools > v0.20).
- `-E`, `--no-omit`: Treats omitting of snapshots (e.g. due to options `-t`/`-T`) as an error.

**Options for auto-clean behavior:**
- `-k`, `--keep <number>`: Sort the snapshots matching `<snapname pattern>` by using `ls -dr` and keep the first `<number>` snapshots; the rest ones will be deleted.
  - 5 snapshots will be kept if this option is not specified.

**Other options:**
- `-q`, `--quiet`: Silent unless an error occurs. Such output is cron-compatible.
- `-h`, `--help`: Print help message and exit.
- `-V`, `--version`: Print version message and exit.
- `--show-all-btrfs`: Print current Btrfs mountpoints and unmounted Btrfs subvolumes in system.

## Cron usage
Choose only one method below will be enough.

### Method: crontab
Suppose you have two Btrfs subvolumes mounted at `/` and `/home`.

In crontab, add these two lines:
```cron
*/5   *   *   *   *   buttersnap /     -n5m -k12 -r
0     0   *   *   *   buttersnap /home -n1d -k7  -r -S"mim" -s"/snapshots"
```

The above cronjob will
- Every 5 minutes, create a read-only snapshot of `/` with name prefix `5m_` keeping 12 generations in `/.snapshots`.
- Every day, create a read-only snapshot of `/home` with name prefix `1d_` keeping 7 generations in `/snapshots/home`.

### Method: polling
Suppose you have a Btrfs subvolume mounted at `/data`.

Find a way to run the commands below regularily (e.g. every 10 minutes).
```cron
buttersnap -r -S"abs" -s <store path> -t3600           /data -n"data_hourly" -k24
buttersnap -r -S"abs" -s <store path> -t$((3600*24))   /data -n"data_daily"  -k7
buttersnap -r -S"abs" -s <store path> -t$((3600*24*7)) /data -n"data_weekly" -k4
```

## License
This program is distributed under the [GNU General Public License](http://www.gnu.org/licenses/gpl.txt).

## History
The script is originally a rework of [QDaniel/btrfs-snap](https://github.com/QDaniel/btrfs-snap), which is a fork of [jf647/btrfs-snap](https://github.com/jf647/btrfs-snap).

### Butter Snap
- Developed by [clsty](https://github.com/clsty).

### btrfs-snap
- Originally by Birger Monsen <birger@birger.sh>
- Readonly and basedir additions by James FitzGibbon <james@nadt.net>
- VFS snapshot naming support by gitmopp (https://github.com/gitmopp)
- Support for snapshotting unmounted btrfs subvolumes by Brian Kloppenborg (https://github.com/bkloppenborg)
- Add switches `-c` (for windows-combitible timestamps) and `-d` (for specifying the snapshot directory) by Lukas Pirl (btrfs-snap@lukas-pirl.de)
- Add switches `-B` (absolute path of snapshot directory) and `-t`/`-T` (time-dependent snapshot) by Michael Walz (btrfs-snap@serpedon.de)
- Other improvements by [chipturner](https://github.com/chipturner), [lpirl](https://github.com/lpirl) and [QDaniel](https://github.com/QDaniel)
