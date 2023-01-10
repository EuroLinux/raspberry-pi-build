%global commit 54fd97ae4066a10b6b02089bc769ceed328737e0
%global shortcommit %(c=%{commit}; echo ${c:0:7})
%global commitdate 20220616

Name:           raspberrypi-userland
Version:        1.git%{shortcommit}
Release:        0%{?dist}
Summary:        Miscellaneous Raspberry Pi utilities

License:        BSD-3-Clause
URL:            https://github.com/raspberrypi/userland/
Source0:        userland.tar.gz
Source1:        rpi.rules
# Install executable, libraries and man pages as per GNU Coding Standards (based
# on https://github.com/raspberrypi/userland/pull/717)
Patch0:         %{name}-0-install.patch
# Unbundle dma-buf.h (see https://github.com/raspberrypi/userland/pull/666)
Patch1:         %{name}-0-use_system_dma-buf.patch
# Unbundle libgps (based on https://github.com/raspberrypi/userland/pull/662)
Patch2:         %{name}-0-use_system_libgps.patch

BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  gpsd-devel
BuildRequires:  systemd-rpm-macros
%ifarch %{arm}
# Raspicam apps (not built on arm64) dlopens libgps
Requires:       gpsd%{?_isa}
%endif
ExclusiveArch:  %{arm} %{arm64}

%description
The %{name} package contains various utilities for interacting with
the Raspberry Pi's VideoCore IV and Miscellaneous Raspberry Pi utilities.


%package libs
Summary: Libraries for the Raspberry Pi's VideoCore IV

%description libs
The %{name}-libs package contains MMAL and other libraries for the
Raspberry Pi's VideoCore IV multimedia processor.


%package devel
Summary:  Development files for %{name}
Requires: %{name}-libs%{?_isa} = %{version}-%{release}
Provides: %{name}-static = %{version}-%{release}

%description devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.


%prep
%autosetup -n userland -p0

# Delete bundles headers
rm host_applications/linux/{libs/sm/dma-buf.h,/apps/raspicam/gps.h}

# libbgps is dlopend. Update .so filename to the current one in Fedora
libgps_so=(%{_libdir}/libgps.so.*)
sed -i "s|^\s*#define\s\+LIBGPS_SO_VERSION\b.*|#define LIBGPS_SO_VERSION \"${libgps_so[0]}\"|" host_applications/linux/apps/raspicam/libgps_loader.h


%build
# - libfdt must be build static (see
#   https://github.com/raspberrypi/userland/pull/333)
# - Move libraries and headers in a subdirectory to avoid conflicts with graphic
#   library packages providing the same filename
%cmake \
%ifarch aarch64
    -DARM64:BOOL=ON \
%endif
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DBUILD_STATIC_LIBS:BOOL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_INCLUDEDIR=include/vc \
    -DCMAKE_INSTALL_LIBDIR=%{_lib}/vc
%cmake_build


%install
%cmake_install

mv $RPM_BUILD_ROOT%{_libdir}/vc/pkgconfig/ $RPM_BUILD_ROOT%{_libdir}/pkgconfig/

install -dm 0755 $RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/
echo "%{_libdir}/vc" >$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/%{name}-%{_lib}.conf

install -Dpm 0644 %{SOURCE1} $RPM_BUILD_ROOT%{_udevrulesdir}/10-rpi.rules


%ldconfig_scriptlets libs


%files
%{_bindir}/dtmerge
%{_bindir}/dtoverlay
%{_bindir}/dtoverlay-post
%{_bindir}/dtoverlay-pre
%{_bindir}/dtparam
%{_bindir}/tvservice
%{_bindir}/vcgencmd
%{_bindir}/vchiq_test
%{_bindir}/vcmailbox
%{_mandir}/man1/dtmerge.1.*
%{_mandir}/man1/dtoverlay.1.*
%{_mandir}/man1/dtparam.1.*
%{_mandir}/man1/tvservice.1.*
%{_mandir}/man1/vcgencmd.1.*
%{_mandir}/man1/vcmailbox.1.*
%{_mandir}/man7/raspiotp.7.*
%{_mandir}/man7/raspirev.7.*
%{_mandir}/man7/vcmailbox.7.*
%ifarch %{arm}
%{_bindir}/containers_check_frame_int
%{_bindir}/containers_datagram_receiver
%{_bindir}/containers_datagram_sender
%{_bindir}/containers_dump_pktfile
%{_bindir}/containers_rtp_decoder
%{_bindir}/containers_stream_client
%{_bindir}/containers_stream_server
%{_bindir}/containers_test
%{_bindir}/containers_test_bits
%{_bindir}/containers_test_uri
%{_bindir}/containers_uri_pipe
%{_bindir}/mmal_vc_diag
%{_bindir}/raspistill
%{_bindir}/raspivid
%{_bindir}/raspividyuv
%{_bindir}/raspiyuv
%{_bindir}/vcsmem
%{_mandir}/man1/raspistill.1.*
%{_mandir}/man1/raspivid.1.*
%{_mandir}/man1/raspividyuv.1.*
%{_mandir}/man1/raspiyuv.1.*
%{_mandir}/man7/raspicam.7.*
%endif


%files libs
%license LICENCE
%dir %{_libdir}/vc/
%{_libdir}/vc/*.so
%ifarch %{arm}
%dir %{_libdir}/vc/plugins/
%{_libdir}/vc/plugins/*.so
%endif
%config %{_sysconfdir}/ld.so.conf.d/%{name}-%{_lib}.conf
%{_udevrulesdir}/10-rpi.rules


%files devel
%{_includedir}/vc/
%{_libdir}/vc/*.a
%{_libdir}/pkgconfig/*.pc


%changelog
* Tue Jan 10 2023 Alex Baranowski <alex@euro-linux.com> - 1
- Make it easier to manage:
 -> Merge ifs for files in spec
 -> Short commit + date of commit
 -> no '^' in name like 0^20220616git54fd97a-1 ...

* Mon Jan 02 2023 Mohamed El Morabity <melmorabity@fedoraproject.org> - 1
- Initial RPM release
