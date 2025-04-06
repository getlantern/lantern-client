package pro

import (
	"context"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// Plans returns the plans available to a user
func (c *proClient) Plans(ctx context.Context) ([]*protos.Plan, error) {
	if v, ok := c.plansCache.Load("plans"); ok {
		resp := v.([]*protos.Plan)
		log.Debugf("Returning plans from cache %s", v)
		return resp, nil
	}
	resp, err := c.FetchPaymentMethodsAndCache(ctx)
	if err != nil {
		return nil, err
	}
	return resp.Plans, nil
}

// DesktopPaymentMethods returns plans and payment methods available for desktop users
func (c *proClient) DesktopPaymentMethods(ctx context.Context) (*protos.PaymentMethodsList, error) {
	return c.paymentMethodsByPlatform(ctx, "desktop")
}

// PaymentMethodsByPlatform returns the plans and payments from cache for the given platform
// if available; if not then call FetchPaymentMethods
func (c *proClient) paymentMethodsByPlatform(ctx context.Context, platform string) (*protos.PaymentMethodsList, error) {
	if platform != "desktop" && platform != "android" {
		return nil, errors.New("invalid platform")
	}
	if v, ok := c.plansCache.Load("paymentMethods"); ok {
		resp := v.(*protos.PaymentMethodsList)
		log.Debugf("Returning payment methods from cache %s", v)
		return resp, nil
	}
	resp, err := c.FetchPaymentMethodsAndCache(ctx)
	if err != nil {
		return nil, err
	}
	desktopProviders, ok := resp.Providers["desktop"]
	if !ok {
		return nil, errors.New("No desktop payment providers found")
	}
	return desktopProviders, nil
}

// FetchPaymentMethodsAndCache returns the plans and payment plans available to a user
// Updates cache with the fetched data
func (c *proClient) FetchPaymentMethodsAndCache(ctx context.Context) (*protos.PaymentMethodsResponse, error) {
	resp, err := c.PaymentMethodsV4(context.Background())
	if err != nil {
		return nil, errors.New("Could not get payment methods: %v", err)
	}
	desktopPaymentMethods, ok := resp.Providers["desktop"]
	if !ok {
		return nil, errors.New("No desktop payment providers found")
	}
	for _, paymentMethod := range desktopPaymentMethods.Methods {
		for j, provider := range paymentMethod.Providers {
			if logos, ok := resp.Icons[provider.Name]; ok {
				for _, logo := range logos.Icons {
					paymentMethod.Providers[j].LogoUrls = append(paymentMethod.Providers[j].LogoUrls, logo)
				}
			}
		}
	}
	//clear previous store cache
	c.plansCache.Delete("plans")
	c.plansCache.Delete("paymentMethods")
	log.Debugf("DEBUG: Payment methods plans: %+v", resp.Plans)
	log.Debugf("DEBUG: Payment methods providers: %+v", desktopPaymentMethods)
	c.plansCache.Store("plans", resp.Plans)
	c.plansCache.Store("paymentMethods", desktopPaymentMethods)
	return resp, nil
}
