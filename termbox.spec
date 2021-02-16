Summary:         A legacy-free alternative to ncurses
Name:            termbox
Version:         1.1.4
Release:         1%{?dist}
License:         MIT
URL:             https://github.com/termbox/termbox
Source:          https://github.com/termbox/termbox/archive/v%{version}/%{name}-%{version}.tar.gz

BuildRequires:   gcc

%description
Termbox is a minimal, legacy-free alternative to ncurses, suitable
for building text-based user interfaces.

%package devel
Summary: Development files for the termbox library
Requires: %{name}%{?_isa} = %{version}-%{release}

%description devel
The header files and libraries for developing applications that use 
the termbox library. Install the termbox-devel package if you want to
develop applications which will use termbox.

%prep
%setup -q
sed -i 's|\blib\b|%{_lib}|g' Makefile

%build
%make_build

%install
%make_install prefix=%{_prefix}
rm -rf $RPM_BUILD_ROOT%{_libdir}/*.{a,la}

%files
%doc README.md
%license COPYING
%{_libdir}/libtermbox.so
%{_libdir}/libtermbox.so.1
%{_libdir}/libtermbox.so.1.0.0

%files devel
%{_includedir}/termbox.h

%changelog
* Mon Feb 15 2021 Adam Saponara <as@php.net> - 1.1.4-1
- initial spec
