<?php

namespace App\Exceptions;

use Exception;

class AuditLogImmutableException extends Exception
{
    /**
     * Create a new exception instance.
     */
    public function __construct(string $message = 'Audit logs are immutable and cannot be modified or deleted.')
    {
        parent::__construct($message);
    }
}
