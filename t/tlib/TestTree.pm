package TestTree;
#
# $Id: $
# $Revision: $
# $Author: $
# $Source:  $
#
# $Log: $
#
use Moose;
use Data::Dumper;
use Test::More;

use namespace::autoclean;

has 'schema'        => (is => 'rw');        # Schema connection

sub structure {
    my ($self, $root, $test_str) = @_;

    is($root->lft, 1, "$test_str - [".$root->id."] Root left is correct");
    my $nodes_count = $root->nodes->count;
    is($root->rgt, $nodes_count * 2, "$test_str - [".$root->id."] Correct number of nodes");
    my $level = 0;
    is($root->level, $level, "$test_str - [".$root->id."] Correct level");
    my $index = 1;
    my $current_node = $root;
    while ($index < $root->rgt) {
        my $next_node = $self->schema->resultset('MultiTree')->search({
            -or => [
                rgt => $index,
                lft => $index,
            ],
        });
        is($next_node->count, 1, "$test_str - [$index] has a node");
        my $node = $next_node->next;
        ok($node->lft < $node->rgt, "$test_str - [$index] left < right");
        ok($node->rgt < $root->rgt || $node->lft == 1, "$test_str - [$index] right < root->right");
        is(($node->rgt - $node->lft) % 2, 1, "$test_str - [$index] left/right diff is odd");

            # we expect (right - 1 - left)/2 descendants
            my @descendants = $node->descendants;
            is(($node->rgt - 1 - $node->lft)/2, scalar @descendants, "$test_str - [$index] correct number of descendants");

        $index++;
    }
}


# This speeds up the code and must be at the end of the package
no Moose;
__PACKAGE__->meta->make_immutable;

1;
