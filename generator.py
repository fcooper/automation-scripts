from bs4 import BeautifulSoup
import multiprocessing
import os

fatal_error = False
f = open('configuration.xml', 'r')

xml_file = f.read()

soup = BeautifulSoup(xml_file, features="xml")

nfsdir = soup.configurations.nfsdir
toolchaindir = soup.configurations.toolchaindir
toolchainprefix = soup.configurations.toolchainprefix
makejobs = soup.configurations.makejobs

kernelarg = soup.configurations.arguments.kernel
dtbarg = soup.configurations.arguments.dtb
modulearg = soup.configurations.arguments.module
buildarg = soup.configurations.arguments.build
installarg = soup.configurations.arguments.install


if nfsdir is None:
	print "NFS directory not specified"
	fatal_error = True
else:
	nfsdir = nfsdir.string.strip()

	if os.path.isdir(nfsdir) is False:
		print "NFS directory isn't a valid directory"
		fatal_error = True



if toolchaindir is None:
	print "Toolchain directory not specified"
	fatal_error = True
else:
	toolchaindir = toolchaindir.string.strip()

	if os.path.isdir(toolchaindir) is False:
		print "Toolchain directory isn't a valid directory"
		fatal_error = True


if toolchainprefix is None:
	print "Toolchain prefix not specified"
	fatal_error = True
else:
	toolchainprefix = toolchainprefix.string.strip()

if makejobs is None:
	print "Make jobs not specified using number of cpu cores instead"

	makejobs = str(multiprocessing.cpu_count())
else:
	makejobs = makejobs.string.strip()

if kernelarg is None:
	print "Kernel argument not specified using default"
	kernelarg = "k"
else:
	kernelarg = kernelarg.string.strip()

if dtbarg is None:
	print "DTB argument not specified using default"
	dtbarg = "d"
else:
	dtbarg = dtbarg.string.strip()

if modulearg is None:
	print "Module argument not specified using default"
	modulearg = "m"
else:
	modulearg = modulearg.string.strip()

if buildarg is None:
	print "Build argument not specified using default"
	buildarg = "b"
else:
	buildarg = buildarg.string.strip()

if installarg is None:
	print "Install argument not specified using default"
	installarg = "i"
else:
	installarg = installarg.string.strip()

#			<name>j6entry</name>
#			<filesystem>j6entry</filesystem>


selected_boards = {}
boards = soup.configurations.boards.findAll("board")

for board in boards:
	name = board.find('name').string

	filesystem = board.filesystem.string

	dtb_list = []
	dtbs = board.dtbs.findAll("dtb")

	for dtb in dtbs:
		dtb_list.append(dtb.string.strip())

	selected_boards[name] = {}
	selected_boards[name]["filesystem"] = filesystem
	selected_boards[name]["dtbs"] = dtb_list

machine_list = selected_boards.keys()

f = open('config', 'w')
temp = "nfs_path=\"%s\"" % nfsdir
f.write(temp+'\n')

temp = "toolchain_dir=%s" % toolchaindir
f.write(temp+'\n')

temp = "toolchain_prefix=\"%s\"" % toolchainprefix
f.write(temp+'\n')

temp = ""
temp = "valid_machines=("+" ".join(machine_list)+")"
f.write(temp+'\n')

temp = "num_jobs="+makejobs
f.write(temp+'\n')

f.write("\n")
f.write("declare -A dtb\n")
f.write("declare -A fs\n")
f.write("declare -A pwr\n")
f.write("declare -A pvr\n")
f.write("\n")

for machine in machine_list:
	name = machine
	filesystem = selected_boards[machine]["filesystem"]

	dtbs = " ".join(selected_boards[machine]["dtbs"])

	temp= "dtb[%s]=%s" % (name,dtbs)
	f.write(temp+"\n")

	temp= "fs[%s]=%s" % (name,filesystem)
	f.write(temp+"\n")
	f.write("\n")
