#!/usr/bin/env python

from os import path
from waflib import Logs

VERSION = '0.0.1'
APPNAME = 'wrote'

top = '.'
out = 'bld'

def options(opt):
  opt.load('compiler_c')
  opt.load('vala')
  opt.load('gnu_dirs')
  
def configure(conf):  
  conf.check_cfg(
    package = 'glib-2.0',
    uselib_store = 'GLIB',
    atleast_version = '2.30.0',
    mandatory = True,
    args = '--cflags --libs')
  
  conf.check_cfg(
    package = 'gtk+-3.0',
    uselib_store = 'GTK',
    atleast_version = '3.2.0',
    mandatory = True,
    args = '--cflags --libs')
    
  env = conf.env
      
  conf.setenv('debug', env)
  
  conf.env['PREFIX'] = path.abspath(path.join(out, 'debug'))
  
  conf.load('compiler_c')
  conf.load('vala')  
  conf.load('gnu_dirs')
  
  conf.define('PREFIX', conf.env['PREFIX'])
  conf.define('LOCALEDIR', conf.env['LOCALEDIR'])
  conf.define('DATADIR', conf.env['DATADIR'])
  
  conf.write_config_header('debug/config.h', 'debug')   
  
  conf.setenv('release', env)
  
  conf.load('compiler_c')
  conf.load('vala')  
  conf.load('gnu_dirs')
  
  conf.define('PREFIX', conf.env['PREFIX'])
  conf.define('LOCALEDIR', conf.env['LOCALEDIR'])
  conf.define('DATADIR', conf.env['DATADIR'])
  
  conf.write_config_header('release/config.h', 'release')

def post_install(ctx):
  print
  Logs.pprint(None, 'Running `fc-cache` ...')
  res = ctx.exec_command('fc-cache')
  if res == 0:
    Logs.pprint('CYAN', 'GOOD')
  else:
    Logs.pprint('RED', 'BAD')
  
  print
  
  return res

def build(bld):
  if not bld.variant:
    bld.fatal("What to %s? Consider calling:\n\twaf %s:release, or\n\twaf %s:debug." % (bld.cmd, bld.cmd, bld.cmd))
    
  wrote = bld.program(
    target = APPNAME,
    uselib = 'GLIB GTK',
    packages = 'glib-2.0 gobject-2.0 gtk+-3.0 config',
    vapi_dirs = ['./vapi'],
    source = bld.path.ant_glob('src/**/*.vala'))
  
  # Install Images
  bld.install_files('${DATADIR}/wrote/images', bld.path.ant_glob('res/images/**/*'))
  bld.install_files('${DATADIR}/fonts/wrote', bld.path.ant_glob('res/fonts/**/*'))
  
  if bld.cmd.startswith("install") or bld.cmd.startswith("uninstall"):
    bld.add_post_fun(post_install)
  
from waflib.Build import BuildContext, CleanContext, \
        InstallContext, UninstallContext

for x in ['debug', 'release']:
  for y in (BuildContext, CleanContext, InstallContext, UninstallContext):
    name = y.__name__.replace('Context','').lower()
    class tmp(y): 
      cmd = name + ':' + x
      variant = x

