---
title: "Automatically adding subuid/subgid mappings"
category: devops
tags: linux containers podman buildah tip
---

Looking into [podman](https://podman.io/), one of the minor niggles I had was this error message:

```
WARN error reading allowed ID mappings: error reading subuid mappings for user "david" and subgid mappings for group "david": No subuid ranges found for user "david" in /etc/subuid
WARN Found no UID ranges set aside for user "david" in /etc/subuid.
WARN Found no GID ranges set aside for user "david" in /etc/subgid.
```

Looking for solutions, I found `--add-subuids` and friends in [usermod(8)](https://man7.org/linux/man-pages/man8/usermod.8.html), but that doesn't provide any support for automatically determining the "correct" values.
Specifically with the already existing entries in `/etc/subuid`, I didn't want to risk a one-off error and create overlapping ID ranges that form a security hole.

Thankfully, I found quick workaround:
the `adduser` command automatically allocates a new range of subuids and subgids.
Using this I was able to create a new user, repurpose the computed ranges for my own account and clean up by deleting the temporary user.

```
root@zion:/etc# adduser --disabled-password --disabled-login --gecos '' tmp
Adding user `tmp' ...
Adding new group `tmp' (1002) ...
Adding new user `tmp' (1002) with group `tmp' ...
Creating home directory `/home/tmp' ...
Copying files from `/etc/skel' ...
root@zion:/etc# git diff subgid subuid
diff --git a/subgid b/subgid
index 31beeb2..858663f 100644
--- a/subgid
+++ b/subgid
@@ -6,3 +6,4 @@ systemd-resolve:362144:65536
 lightdm:558752:65536
 _apt:624288:65536
 nm-openvpn:689824:65536
+tmp:427680:65536
diff --git a/subuid b/subuid
index 31beeb2..858663f 100644
--- a/subuid
+++ b/subuid
@@ -6,3 +6,4 @@ systemd-resolve:362144:65536
 lightdm:558752:65536
 _apt:624288:65536
 nm-openvpn:689824:65536
+tmp:427680:65536
root@zion:/etc#
```

Not only did it automatically create the entries for me, it also found a gap in the existing mappings that was vacated by a previous user being deleted.
Now I can rename the entries in the two files and delete the `tmp` user.

```
root@zion:/etc# vi subuid subgid
2 files to edit
root@zion:/etc# deluser --remove-home tmp
Looking for files to backup/remove ...
Removing files ...
Removing user `tmp' ...
Warning: group `tmp' has no more members.
Done.
root@zion:/etc# git diff subgid subuid
diff --git a/subgid b/subgid
index 31beeb2..c6a491d 100644
--- a/subgid
+++ b/subgid
@@ -6,3 +6,4 @@ systemd-resolve:362144:65536
 lightdm:558752:65536
 _apt:624288:65536
 nm-openvpn:689824:65536
+david:427680:65536
diff --git a/subuid b/subuid
index 31beeb2..c6a491d 100644
--- a/subuid
+++ b/subuid
@@ -6,3 +6,4 @@ systemd-resolve:362144:65536
 lightdm:558752:65536
 _apt:624288:65536
 nm-openvpn:689824:65536
+david:427680:65536
root@zion:/etc# etckeeper commit -m 'Create subuid and subgid mappings for `david`'
[master 8b438f5] Create subuid and subgid mappings for `david`
 Author: David Schmitt <david@black.co.at>
 4 files changed, 2 insertions(+), 2 deletions(-)
root@zion:/etc#
```
