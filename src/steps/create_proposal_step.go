package steps

import (
	"github.com/git-town/git-town/v9/src/browser"
	"github.com/git-town/git-town/v9/src/git"
	"github.com/git-town/git-town/v9/src/hosting"
)

// CreateProposalStep creates a new pull request for the current branch.
type CreateProposalStep struct {
	EmptyStep
	Branch string
}

func (step *CreateProposalStep) Run(run *git.ProdRunner, connector hosting.Connector) error {
	parentBranch := run.Config.Lineage().Parent(step.Branch)
	prURL, err := connector.NewProposalURL(step.Branch, parentBranch)
	if err != nil {
		return err
	}
	browser.Open(prURL, run.Frontend.FrontendRunner, run.Backend)
	return nil
}
