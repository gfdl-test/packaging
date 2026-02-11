# Copyright Spack Project Developers. See COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class FreCommands(Package):
    """FRE Commands - Flexible Runtime Environment command-line tools"""

    homepage = "https://gitlab.gfdl.noaa.gov/fre-legacy/fre-commands"
    git = "https://gitlab.gfdl.noaa.gov/fre-legacy/fre-commands.git"

    license("NOASSERTION")

    version("bronx-23", branch="release/bronx-23")

    depends_on("git", type="build")

    def install(self, spec, prefix):
        # The git clone is already done by Spack into the stage directory
        # Just copy everything to the install prefix
        install_tree(".", prefix)
