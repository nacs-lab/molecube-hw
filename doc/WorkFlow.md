This is the document describing the workflow for this repository.
This includes the workflow for modifying code, for generating outputs
and for version control of the code.

# Motivation
Xilinx provides multiple ways to work with a project, each with their tradeoffs.
For this repo, our goals are,

* Easy for new maintainer

    We won't have full time programmers/engineers working on this, rather graduate students
    that have to pick this up quickly.

* Easy to upgrade

    Although we won't always use the latest tool from xilinx, we should minimize the
    barrier for doing that. If upgrading the tool is too hard, it'll likely never
    happen (see previous point).

* Compatible with version control (`git`)

    We should check in mostly text files and only ones necessary for compilation
    (or to achieve other goals like better compatibility).

* Compatible with developing from different users/directories

    Avoid absolute path as much as possible.

* Compatible with command line compilation

    Make it easy to package the final result.

For these reasons, we use a project-based GUI workflow and following the version control
guideline from Xilinx. The project-based GUI workflow, compared to projectless or
scripting workflow, provides better integration of different components and a easier to
use GUI environment, making it much easier to learn than the alternatives.
Following the version control guideline and checking in all the files recommended makes sure
that we are as version control compatible as we could be while keeping all the files
that's needed to compile the project using a newer version of vivado.
Xilinx does a reasonably good job making sure the files aren't changing unnecessarily
and that the files checked in does not have absolute paths in them though there are
a few corner cases that needs to be fixed. (See workflow below)

We also use a global synthesis workflow (`None` in the setting)
and outputs into default directory since this make sure
the generated files can easily be ignored and we won't check in references with absolute paths.
Our project is small enough that the speed up from a hierarchical work flow,
where different components are compiled in parallel separately before combining,
is not very important. If this isn't the case anymore, we can switch to a "out-of-context"
synthesis workflow (`Hierarchical` or `Singular` in the setting)
and add more detailed git ignore rules as necessary since the generated results to be ignored
will be stored aloneside files that need to be checked in.

# Directory structure

The structure of the repo is mostly determine by the workflow.

Following the Xilinx guideline, the project directory is [`project_molecube`](../project_molecube)
in which the only relevant file is the project file [`project_molecube.xpr`](../project_molecube/project_molecube.xpr),
all other files there are ignored from the repo.

The source files for the project are located in other top-level directories which currently
include [`constr_1`](../constr_1) (constraints) and [`design_1`](../design_1) (block design).
The block design directory [`design_1`](../design_1) contains most of the files for the
project including all the files generated from the IPs used.

The project also use other custom IPs, e.g. `pulse_controller`. These are located in
[`custom_ip`](../custom_ip) which are added to the IP library of the projects.
Note that this is not the code that is used directly in the project.
Vivado copies all necessary IP source files [into the design](../design_1/ipshared/)
so that an updated IP will not break an old design that requires an earlier version.
Any modification to the custom IP, similar to an upgrade of the Xilinx IP, requires a manual
upgrade of the IP.

# Workflow for modifying custom IP

If the external interface (ports, parameters etc) does not change, simply editing the HDL files
should be enough. Vivado, when running, is smart enough to automatically pick up the change
and prompt you for updating the IP in the project.
This may not work if Vivado wasn't running in which case `touch`ing a source file after starting
Vivado should allow it to pick up the update.

The workflow mentioned above bypasses the IP packager from Xilinx.
It is OK when we are not changing anything exposed by the package (it's API in some sense)
and since we don't need to let Xilinx manage our IP version (we have `git` for that
and since the custom IP and design version will never deviate as long as they are still
in the same repo, we don't need to worry about version compatibility.)
If for some reason the IP packager is necessary, it can be launched from Vivado
through the right click menu on the IP to be edited in the board design or IP catalog.
After updating all the information, the IP packager should update the `component.xml` file
and Vivado should pick up the new version.
Note that this is the few cases that absolute paths can be checked into the library,
see below about filtering them out.

Whichever method used, please make sure the project/block design is fully updated before
making a commit that is intended to "work".
(Intermediate change commits without updating the whole project
are OK for big changes though unless there's reason the partially updated IP
cannot work, it is better to have the intermediate commit either squash out or
fully updated.) See below for note about absolute path and
updating the project after making changes.

# Workflow for modifying the block design

There may not be strong need to add new source files, the project isn't particularly complex.
However, if needed, make sure to follow the Xilinx guide and keep all source files
out of [`project_molecube`](../project_molecube) and do not let Vivado copy
them into the project.

While Vivado is reasonably friendly to version control, there are a few aspects
where it is less than ideal.

* Absolute paths

    There is an absolute path in the [project file](../project_molecube/project_molecube.xpr).
    It is, as far as I can tell, unavoidable and harmless,
    apart from exposing your local directory structure to the public.

    Another also harmless but more annoy and avoidable source of absolute path is
    from the IP packager. The generated `component.xml` file contains
    `xilinx:tag` elements that constains an absolute path to the custom IP.
    It seems to be insignificant for the project
    but each run of the IP packager will accumulate more entries.
    It is also copied into [`design_1`](../design_1) by Vivado (to preserve a "locked" copy I assume) and even though
    [one Xilinx post](https://forums.xilinx.com/t5/Design-Entry/IP-component-file-keeps-growing-not-version-control-friendly/m-p/1092248/highlight/true#M23670)
    recommand against checking in any `.xml` files
    these files seems to be necessary (especially the ones copied into [`design_1`](../design_1),
    compilation fails if the `.xml` files are deleted).
    Checking these in seems harmless but if one want to keep the repo clean (recommanded)
    they can be removed by running `sed -i -e '/^ *<xilinx:tag /d'` on the relevant files.
    A git pre-commit hook should also work but cleaning up `component.xml`
    before letting Vivado copy it is better.

* Time stamp

    Some file generation steps cause timestamps to be recorded
    in the generated file/project files. Some of these might be used for update detection
    so it may not be generally a good idea to omit/revert these changes. However, if
    a commit was going to contain only time stamp changes or if the time stamp is
    simply in the comment (header) of generated HDL file, it should be safe to omit them
    as see fit.

* Run state

    The project file also records some states about the last/latest runs.
    Try not to leave the project in a partially run synthesis/implementation state to avoid
    causing flip-flop in these state recording in the project.
    (If nothing else is worth committing these changes can also simply be omitted.)

    It's also important to keep the run consistent before committing so that the whole project
    is always in sync, see below.

* Run statistics

    These are saved in the project files as `Option` elements with a `Name` property
    starting with `WT` (webtalk) and a `Val` property of an integer.
    Changes to these can be safely ignored.

    As of writing these include

    ```xml
    <Option Name="WTXSimLaunchSim" Val="0"/>
    <Option Name="WTModelSimLaunchSim" Val="0"/>
    <Option Name="WTQuestaLaunchSim" Val="0"/>
    <Option Name="WTIesLaunchSim" Val="0"/>
    <Option Name="WTVcsLaunchSim" Val="0"/>
    <Option Name="WTRivieraLaunchSim" Val="0"/>
    <Option Name="WTActivehdlLaunchSim" Val="0"/>
    <Option Name="WTXSimExportSim" Val="0"/>
    <Option Name="WTModelSimExportSim" Val="0"/>
    <Option Name="WTQuestaExportSim" Val="0"/>
    <Option Name="WTIesExportSim" Val="0"/>
    <Option Name="WTVcsExportSim" Val="0"/>
    <Option Name="WTRivieraExportSim" Val="0"/>
    <Option Name="WTActivehdlExportSim" Val="0"/>
    ```

* Binary file

    Vivado creates a few binary files generated from the IPs/for the block design.
    The ones currently in the repo are some simulation libraries (`*.so` and `*.dll`)
    and some `*.hwdef` files, which AFAICT are zip file of some other directory.
    Fortunately these files aren't changed particularly frequently so I decided to just
    live with them for now without digging much deeper.

From the small number of direct user input,
together with the IP library (and other data from Vivado itself),
Vivado generates the files used as input to the synthesis (and then implementation) run.
These are the files that are checked in as recommended by Xilinx.
For ease of testing intermediate commits, the project should always be updated to have
all the files generated/updated, so that every commit always need the same steps to compile.
Earlier commits of this repo may be updated to a different stage before a full synthesis
is possible.

The tested ways of generating these files are launching a synthesis run using any of the allowed
settings (local or generate script only).
However, if not run till the start of the implementation run,
the project file will record a different run state so launching a implementation run
is preferred before committing.

Other related updates include

* Generate HDL wrapper on `design_1_i`
  (one level below `design_1_wrapper` under `Design Sources` in the Sources sub window)

    This does not generate all the files but merely the top-level HDL files.
    Some earlier commit of this repo were generated to this stage.

* Generate Output Products on `design_1_i`
  (Same right click menu as above)

    It seems to be generating the same files though it also seems to handle update differently
    (especially when there's manual updates). When certain metadata of the imported
    IP changes this seems to generate a "more correct" version
    (the hash of the IP in [`design_1/ipshared`](../design_1/ipshared))
    though it required manually resetting the output to remove old copies.

    I'm not 100% sure if this should be the standard step.
    However, I believe running this (potentially with a reset first) is at least useful
    for checking if the result deviate from the current state in any significant way
    (i.e. more than time stamps).
    Running this also won't force the runs to be resetted and may cause a smaller
    change on the project files.

# Workflow for generating output (command line)

[`script/build.tcl`](../script/build.tcl) can be used to generate the bitstream
from command line without a GUI. Run it in Vivado batch mode using command

```sh
vivado -mode batch [-nolog] -source script/build.tcl -tclargs [-j <number of processes to use>] -proj project_molecube/project_molecube.xpr -bit <output path of .bit file>
```

The command above assumes running from the toplevel directory of the repo.
When running from a different path,
change the paths to the `build.tcl` script and the project file accordingly.

Options in `[]` are optional.
The optional `-j <number of processes to use>` changes the number of parallel processes to use.
`<output path of .bit file>` should be replaced with the desired output file name.
The file must have a `.bit` extention and a file with the extention replaced with `.bin`
will also be generated under the same path.
The `.bin` file is the bitstream without the header that should be sent to the FPGA
(`/boot/system.bit.bin` on the SD card).

Other scripts for generating other boot files may be added later and they may require Vitis
in additional to Vivado to be installed.

# Workflow for git

It is generally safe to commit at any stage (afterall, revert is easy).
However, it is recommanded to follow the steps below to clean up the repo before committing.

* Make sure `xilinx:tag` are stripped out.
* All the files are fully generated/updated
  and the state of the run did not change
  (at least start of implementation).
* Avoid checking in unnecessary time stamp changes if possible.
* Avoid checking in statistics if possible.

Details for each of the steps are documented above.
