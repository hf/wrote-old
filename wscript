#!/usr/bin/env python

import os
import waflib

APPNAME = 'wrote'
VERSION = '0.0.1'

top = '.'
out = 'bld'

def options(opts):
  opts.load('compiler_c')
  opts.load('vala')
  opts.load('gnu_dirs')

  opts.add_option('--local',
    action='store_true',
    dest='local',
    default = False,
    help = "Whether this is a local (debug) build.")

def configure(conf):
  conf.env['LOCAL'] = conf.options.local

  if conf.options.local:
    waflib.Logs.pprint('CYAN', 'Configuring for a local build.\n' +
      'This means that you shouldn\'t try to install this globally.')

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

  if conf.options.local:
    conf.env['PREFIX'] = os.path.abspath(os.path.join(out, 'local'))

  conf.load('compiler_c')
  conf.load('vala', funs='')
  conf.load('gnu_dirs')

  conf.check_vala(min_version = (0, 15, 1))

  conf.define('PREFIX', conf.env['PREFIX'])
  conf.define('LOCALEDIR', conf.env['LOCALEDIR'])
  conf.define('DATADIR', conf.env['DATADIR'])

  conf.write_config_header('config.h')

def post(bld):
  if bld.is_install and not bld.env['LOCAL']:

    waflib.Logs.info("Updating fonts cache (fc-cache)")
    fccache = bld.exec_command("fc-cache")

    waflib.Logs.info("Updating hicolor icon cache (gtk-update-icon-cache-3.0)")
    hicolor = bld.exec_command("gtk-update-icon-cache-3.0 --ignore-theme-index %s"
      % (os.path.join(bld.env['DATADIR'], 'icons/hicolor')))


def build(bld):
  if bld.env['LOCAL']:
    action = 'Building'

    if bld.is_install:
      action = 'Installing'

    waflib.Logs.pprint('CYAN', '\n%s locally.\n' % (action))

  wrote = bld.program(
    target = APPNAME,
    uselib = 'GLIB GTK',
    lib = ['m'],
    packages = 'glib-2.0 gobject-2.0 gtk+-3.0 config',
    vapi_dirs = ['./vapi'],
    source = bld.path.ant_glob('src/**/*.vala'))

  if bld.env['LOCAL']:
    wrote.vala_defines = ['DEBUG']

  bld.add_post_fun(post)

  bld.install_files('${DATADIR}/wrote/images', bld.path.ant_glob('res/images/**/*'))
  bld.install_files('${DATADIR}/fonts/wrote', bld.path.ant_glob('res/fonts/**/*'))
  bld.install_files('${DATADIR}/applications', 'res/wrote.desktop')

  for icon in os.listdir('res/icons'):
    size = icon.split('.')[0]
    size = "%sx%s" % (size, size)
    bld.install_as('${DATADIR}/icons/hicolor/%s/apps/wrote.png' % (size), os.path.join('res/icons', icon))

  if bld.env['LOCAL'] and not bld.is_install:
    waflib.Scripting.run_command('install')
