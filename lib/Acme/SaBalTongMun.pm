package Acme::SaBalTongMun;
use Moose;
# ENCODING: utf-8
# ABSTRACT: make a round robin (사발통문, 沙鉢通文)

use namespace::autoclean;

=head1 SYNOPSIS

    use Acme::SaBalTongMun;
    
    my $sabal = Acme::SabalTongMun->new(
        radius    => 30,
        font      => '/home/keedi/.fonts/NanumGothic.ttf',
        font_size => 20;
        color     => '#0000FF',
        people    => [
            'a3r0',
            'jeen',
            'keedi',
            'saillinux',
        ],
    );
    
    my $image->generate;
    
    binmode STDOUT;
    print $image->png;

=head1 DESCRIPTION

This module generates a round robin.
The round robin is known as "사발통문(沙鉢通文)" in Korea.
Since all members of the group doesn't have a order,
it has been used to hide the leader of the group.
The origin of the round robin in Korea is 
Donghak Peasants Revolution(동학농민혁명, 東學農民運動).

=cut

use common::sense;
use GD;
use List::Util qw( max );

=attr radius

This attribute stores the radius
which is the center circle of the round robin.

=cut

has 'radius' => ( isa => 'Int', is => 'rw', required => 1 );

=attr font

This attribute stores the TrueType(*.ttf) font path.
Only the font which has unicode charmap is allowed.

=cut

has 'font' => ( isa => 'Str', is => 'rw', required => 1 );

=attr font_size

This attribute stores the size of the font.

=cut

has 'font_size' => ( isa => 'Int', is => 'rw', required => 1 );

=attr font_charset

This attribute stores the charset of the font.
This is optional and the default value is "Unicode".

=cut

has 'font_charset' => ( isa => 'Str', is => 'rw', default => 'Unicode' );

=attr color

This attribute stores the color of the font.

=cut

has 'color' => ( isa => 'Str', is => 'rw', required => 1 );

=attr people

This attribte is an arrayref of strings
that are the members of the round robin.

=cut

has 'people' => ( isa => 'ArrayRef[Str]', is => 'rw', required => 1 );

=method new

    my $sabal = Acme::SabalTongMun->new(
        radius    => 30,
        font      => '/home/keedi/.fonts/NanumGothic.ttf',
        font_size => 20;
        color     => '#0000FF',
        people    => [
            'a3r0',
            'jeen',
            'keedi',
            'saillinux',
        ],
    );

This method will create and return Acme::SabalTongMun object.

=method generate

    my $image = $sabal->generate;

This method will return GD::Image object.

=cut

sub generate {
    my $self = shift;

    my $max_string_width
        = max( map length, @{$self->people} ) * $self->font_size;

    my $cx = $self->radius + $max_string_width;
    my $cy = $self->radius + $max_string_width;
    my $width  = ( $self->radius + $max_string_width ) * 2;
    my $height = ( $self->radius + $max_string_width ) * 2;

    my $angle = ( 2 * 3.14 ) / @{$self->people};

    #
    # Make GD::Image
    #
    my $image = GD::Image->new($width, $height);

    my $white = $image->colorAllocate( _get_rgb("#FFFFFF") );
    my $black = $image->colorAllocate( _get_rgb("#000000") );

    # make the background transparent and interlaced
    $image->transparent( _get_rgb("#FFFFFF") );
    $image->interlaced('true');

    my $dest_angle = 0;
    for my $string ( @{$self->people} ) {
        my $dest_x = $cx + ( $self->radius * cos $dest_angle );
        my $dest_y = $cy + ( $self->radius * sin $dest_angle );

        my $string_angle = (2 * 3.14) - $dest_angle;

        $image->stringFT(
            $image->colorAllocate( _get_rgb( $self->color ) ),  # fgcolor
            $self->font,                                        # .ttf path
            $self->font_size,                                   # point size
            $string_angle,                                      # rotation angle
            $dest_x,                                            # X coordinates
            $dest_y,                                            # Y coordinates
            $string,
            {
                charmap     => $self->font_charset,
            },
        );

        $dest_angle += $angle;
    }

    return $image;
}

sub _get_rgb { map hex, $_[0] =~ m/^#(..)(..)(..)$/ }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
