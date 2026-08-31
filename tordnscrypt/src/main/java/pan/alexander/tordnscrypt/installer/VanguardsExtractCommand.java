/*
    This file is part of InviZible Pro.

    InviZible Pro is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    InviZible Pro is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with InviZible Pro.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2019-2025 by Garmatin Oleksandr invizible.soft@gmail.com
 */

package pan.alexander.tordnscrypt.installer;

import android.content.Context;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import pan.alexander.tordnscrypt.utils.filemanager.FileManager;

import static pan.alexander.tordnscrypt.utils.logger.Logger.loge;
import static pan.alexander.tordnscrypt.utils.logger.Logger.logi;

public class VanguardsExtractCommand extends AssetsExtractCommand {
    private final String appDataDir;

    public VanguardsExtractCommand(Context context, String appDataDir) {
        super(context);
        this.appDataDir = appDataDir;
    }

    @Override
    public void execute() throws Exception {
        String vanguardsDir = appDataDir + "/app_data/vanguards";
        String vanguardsConfPath = vanguardsDir + "/vanguards.conf";

        File dir = new File(vanguardsDir);
        if (!dir.exists() && !dir.mkdirs()) {
            loge("VanguardsExtractCommand: failed to create " + vanguardsDir);
            return;
        }

        File conf = new File(vanguardsConfPath);
        if (conf.exists()) {
            logi("VanguardsExtractCommand: vanguards.conf already exists, skipping");
            return;
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(assets.open("vanguards.conf")))) {
            List<String> lines = new ArrayList<>();
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
            FileManager.writeTextFileSynchronous(context, vanguardsConfPath, lines);
            logi("VanguardsExtractCommand: wrote vanguards.conf OK");
        } catch (Exception e) {
            loge("VanguardsExtractCommand: failed to write vanguards.conf", e);
        }
    }
}
