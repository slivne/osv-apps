.PHONY: module test clean
module: ROOTFS usr.manifest

RAILS_VER=4.1.6

sqlite-autoconf-3080500.tar.gz:
	wget "http://www.sqlite.org/2014/sqlite-autoconf-3080500.tar.gz"

sqlite-autoconf-3080500: sqlite-autoconf-3080500.tar.gz
	tar xvf sqlite-autoconf-3080500.tar.gz
sqlite-autoconf-3080500/.libs/libsqlite3.so.0.8.6: sqlite-autoconf-3080500
	cd sqlite-autoconf-3080500 && ./configure && make CFLAGS="-fPIC -DHAVE_MREMAP=0"
	
ROOTFS/libsqlite3.so.0: sqlite-autoconf-3080500/.libs/libsqlite3.so.0.8.6
	cp sqlite-autoconf-3080500/.libs/libsqlite3.so.0.8.6 ROOTFS/libsqlite3.so.0
tmp/bin/rails: 
	GEM_HOME=tmp PATH=tmp/bin:$$PATH gem install --no-ri --no-rdoc rails -v ${RAILS_VER}
	GEM_HOME=tmp PATH=tmp/bin:$$PATH gem install --no-ri --no-rdoc railties -v ${RAILS_VER}
tmp/bin/bundle: 
	GEM_HOME=tmp PATH=tmp/bin:$$PATH gem install --no-ri --no-rdoc bundler
ROOTFS/osv_test: tmp/bin/rails tmp/bin/bundle
	mkdir -p ROOTFS
	env GEM_HOME=tmp PATH=tmp/bin:$$PATH tmp/bin/rails new ROOTFS/osv_test
	cd ROOTFS/osv_test && patch -p0 < ../../osv_test.patch
	mv ROOTFS/osv_test/Gemfile ROOTFS/osv_test/Gemfile.old
	grep -v spring ROOTFS/osv_test/Gemfile.old > ROOTFS/osv_test/Gemfile
	echo "gem 'therubyracer',  platforms: :ruby" >> ROOTFS/osv_test/Gemfile
gems: ROOTFS/osv_test 
	cd ROOTFS/osv_test && env GEM_HOME=../../tmp PATH=../../tmp/bin:$$PATH ../../tmp/bin/bundle install --path ../../gems
	cd ROOTFS/osv_test && env GEM_HOME=../../gems/ruby/2.1.0 gem install tzinfo-data json
	cd ROOTFS/osv_test && env GEM_HOME=../../tmp PATH=../../tmp/bin:$$PATH ../../tmp/bin/bundle exec rails g scaffold item name:string price:integer description:text
	cd ROOTFS/osv_test && env GEM_HOME=../../gems/ruby/2.1.0 ../../gems/ruby/2.1.0/bin/rake db:migrate
ROOTFS/usr/lib/ruby/gems: gems
	mkdir -p ROOTFS/usr/lib/ruby/gems
	cp -a gems/ruby/2.1.0 ROOTFS/usr/lib/ruby/gems/

ROOTFS: ROOTFS/usr/lib/ruby/gems ROOTFS/libsqlite3.so.0

usr.manifest:
	echo '/osv_test/**: $${MODULE_DIR}/ROOTFS/osv_test/**' >> usr.manifest
	echo '/usr/lib/ruby/gems/**: $${MODULE_DIR}/ROOTFS/usr/lib/ruby/gems/**' >> usr.manifest
	echo '/libsqlite3.so.0: $${MODULE_DIR}/sqlite-autoconf-3080500/.libs/libsqlite3.so.0.8.6' >> usr.manifest
	find ROOTFS/usr/lib/ruby/gems -name '*.so' -exec ldd {} \;|awk '{print $$1,":",$$3}'|grep "/lib64"|grep -v "ld-linux"|grep -v "libc.so"|grep -v "libpthread.so"|grep -v "libdl.so"|grep -v "libm.so"|grep -v "libstdc++"|grep -v "libgcc_s"|grep -v "librt"|grep -v "sqlite3"|grep -v "libssl"|sort|uniq|sed -e "s/ //" \
		>> usr.manifest

test:
	python test.py

clean:
	rm -rf usr.manifest sqlite-autoconf-3080500 *.tar.gz ROOTFS tmp gems
