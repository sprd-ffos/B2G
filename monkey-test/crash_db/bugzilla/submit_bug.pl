##############################################################################
# Name:     submit_bug.pl
# Purpose:  自动提交bug
# Author:   weixian.kong(weixian.kong@spreadtrum.com)
# Created:  2013-01-08
##############################################################################

#!/usr/bin/perl -w
use strict;
use lib qw(lib);
use Getopt::Long;
use Pod::Usage;
use File::Basename qw(dirname);
use File::Spec;
use HTTP::Cookies;
use XMLRPC::Lite;

# 公司外部internet登录
# my $Bugzilla_uri = 'http://222.66.158.130/bugzilla/xmlrpc.cgi';
# 公司外网登录
my $Bugzilla_uri = "http://bugzilla.spreadtrum.com/bugzilla/xmlrpc.cgi";
# 内网登录
# my $Bugzilla_uri = "http://172.16.0.58/bugzilla/xmlrpc.cgi";
my $Bugzilla_login = "weixian.kong";    # bugzilla帐号名
my $Bugzilla_password = "12qwASzx";     # 密码
my $Bugzilla_remember = "1";
my $bug_content_file = "bug_content.txt";

# We will use this variable for SOAP call results.
my $soapresult;

# We will use this variable for function call results.
my $result;

# 生成cookies文件
# Cookies are only saved if Bugzilla's rememberlogin parameter is set to one of
#    - on
#    - defaulton (and you didn't pass 0 as third parameter to User.login)
#    - defaultoff (and you passed 1 as third parameter to User.login)
my $cookie_jar =
    new HTTP::Cookies('file' => File::Spec->catdir(dirname($0), 'cookies.txt'),
                      'autosave' => 1);

# 初始化
my $proxy = XMLRPC::Lite->proxy($Bugzilla_uri,
                                'cookie_jar' => $cookie_jar);

# 检测bugzilla版本信息
$soapresult = $proxy->call('Bugzilla.version');
_die_on_fault($soapresult);
print 'Connecting to a Bugzilla of version ' . $soapresult->result()->{version} . ".\n";


# 登录bugzilla
if (defined($Bugzilla_login)) {
    if ($Bugzilla_login ne '') {
        # Log in.
        $soapresult = $proxy->call('User.login',
                                   { login => $Bugzilla_login, 
                                     password => $Bugzilla_password,
                                     remember => $Bugzilla_remember } );
        _die_on_fault($soapresult);
        print "Login successful.\n";
    }
    else {
        # Log out.
        $soapresult = $proxy->call('User.logout');
        _die_on_fault($soapresult);
        print "Logout successful.\n";
    }
}

# 调用bugzilla webservice的Bug.create接口
if ($bug_content_file) {
    $soapresult = $proxy->call('Bug.create', do "$bug_content_file" );
    _die_on_fault($soapresult);
    $result = $soapresult->result;

    if (ref($result) eq 'HASH') {
        foreach (keys(%$result)) {
            print "$_: $$result{$_}\n";
        }
    }
    else {
        print "$result\n";
    }

}
# Log out
# 先将$Bugzilla_login 置空
$Bugzilla_login = '';
$soapresult = $proxy->call('User.logout');
 _die_on_fault($soapresult);
print "Logout successful.\n";


sub _die_on_fault {
    my $soapresult = shift;

    if ($soapresult->fault) {
        my ($package, $filename, $line) = caller;
        die $soapresult->faultcode . ' ' . $soapresult->faultstring .
            " in SOAP call near $filename line $line.\n";
    }
}

sub _syntaxhelp {
    my $msg = shift;

    print "Error: $msg\n";
    pod2usage({'-verbose' => 0, '-exitval' => 1});
}

# 将提交结果显示到控制台，如果是system方法调用此程序可以将执行结果返回到调用程序
print $$result{id}."\n";

1; # 如果是由别的perl脚本来调用此脚本，需要加上此行表示正常执行结束
