//go:build linux

package test

import (
	"fmt"
	"math/rand"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test_Case1(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UTC().UnixNano())
	uniqueId := rand.Intn(1000)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../test_stack",
		Vars: map[string]interface{}{
			"uniqueid": uniqueId,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	lbIP := terraform.Output(t, terraformOptions, "lb_pip")
	// sleep 30 seconds
	time.Sleep(30 * time.Second)

	webSiteURL := "http://" + lbIP

	resp, err := http.Get(webSiteURL)

	if err != nil {
		fmt.Println(err)
	}
	defer resp.Body.Close()

	// asserting website is responding
	assert.Equal(t, resp.StatusCode, 200)
}
