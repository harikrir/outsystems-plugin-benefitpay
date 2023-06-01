var fs = require('fs'), path = require('path');

module.exports = function(ctx) {
    rootdir = ctx.opts.projectRoot,
    android_dir = path.join(ctx.opts.projectRoot, 'platforms/android');
    sdk_file = path.join(ctx.opts.projectRoot, 'platforms/android/app/libs/benefitinappsdk-1.0.23.aar');
    dest_sdk_folder = path.join(ctx.opts.projectRoot, 'platforms/android/libs');
    dest_sdk_file = path.join(ctx.opts.projectRoot, 'platforms/android/libs/benefitinappsdk-1.0.23.aar');

    if(!fs.existsSync(sdk_file)){
        console.log(sdk_file + ' not found. Skipping');
        return;
    }else if(!fs.existsSync(android_dir)){
        console.log(android_dir + ' not found. Skipping');
       return;
    }

    if (!fs.existsSync(dest_sdk_folder)){
        console.log("Creating libs folder...");
        fs.mkdirSync(dest_sdk_folder);
    }

    console.log('Copy ' + sdk_file + ' to ' + dest_sdk_folder);
    fs.createReadStream(sdk_file).pipe(fs.createWriteStream(dest_sdk_file));
}
